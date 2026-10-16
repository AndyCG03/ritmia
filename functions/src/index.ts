import {initializeApp} from "firebase-admin/app";
import {getAuth} from "firebase-admin/auth";
import {getFirestore,FieldValue,Timestamp,DocumentSnapshot} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import {onCall,HttpsError} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {defineBoolean} from "firebase-functions/params";
import {logger} from "firebase-functions";
import {createHash} from "node:crypto";
import {z} from "zod";
import {subscriptionSchema,canCreate,revisionMatches,dueReminders,localDay,Subscription} from "./domain.js";
initializeApp();
const db=getFirestore();
const requireAppCheck=defineBoolean("REQUIRE_APP_CHECK",{default:false});
const emailDeliveryEnabled=defineBoolean("EMAIL_DELIVERY_ENABLED",{default:false});
const options={region:"us-central1",enforceAppCheck:requireAppCheck,maxInstances:10};
function requireUid(auth:{uid:string}|undefined):string{
  if(!auth)throw new HttpsError("unauthenticated","Sign in first");
  return auth.uid;
}
function invalid():never{throw new HttpsError("invalid-argument","Invalid input");}
async function cleanup(path:string|null|undefined):Promise<void>{
  if(!path)return;
  try{await getStorage().bucket().file(path).delete({ignoreNotFound:true});}
  catch(error){logger.warn("Logo cleanup pending",{path,error});}
}
export const saveSubscription=onCall(options,async request=>{
  const uid=requireUid(request.auth),parsed=subscriptionSchema.safeParse(request.data);
  if(!parsed.success)invalid();
  const input=parsed.data,root=db.doc(`users/${uid}`),record=root.collection("subscriptions").doc(input.id);
  if(input.logoPath!==null&&!new RegExp(`^users/${uid}/logos/${input.id}/[0-9]+\\.png$`).test(input.logoPath))invalid();
  let oldLogo:string|null=null;
  const result=await db.runTransaction(async tx=>{
    const [current,usage,billing]=await Promise.all([
      tx.get(record),tx.get(root.collection("private").doc("usage")),tx.get(root.collection("private").doc("billing"))]);
    const count=Number(usage.get("count")??0);
    const expiry=billing.get("expiresAt");
    const pro=billing.get("plan")==="pro"&&expiry instanceof Timestamp&&expiry.toMillis()>Date.now();
    if(!current.exists&&!canCreate(count,pro))throw new HttpsError("resource-exhausted","Free plan has five slots");
    const revision=Number(current.get("revision")??0);
    if(!revisionMatches(input.revision,revision))throw new HttpsError("aborted","Record changed");
    if(input.logoPath!==null){
      const logoRevision=Number(input.logoPath.split("/").pop()!.split(".")[0]);
      if(logoRevision>revision)invalid();
    }
    oldLogo=current.get("logoPath")??null;
    const result={...input,revision:revision+1,updatedAt:FieldValue.serverTimestamp()};
    tx.set(record,result);
    if(!current.exists)tx.set(root.collection("private").doc("usage"),{count:count+1},{merge:true});
    return {...input,revision:revision+1};
  });
  if(oldLogo!==null&&oldLogo!==result.logoPath)await cleanup(oldLogo);
  return result;
});
export const deleteSubscription=onCall(options,async request=>{
  const uid=requireUid(request.auth);
  const parsed=z.object({id:z.string().regex(/^[a-zA-Z0-9_-]{20}$/),revision:z.number().int().min(0)}).strict().safeParse(request.data);
  if(!parsed.success)invalid();
  const root=db.doc(`users/${uid}`),record=root.collection("subscriptions").doc(parsed.data.id);
  let logo:string|null=null;
  await db.runTransaction(async tx=>{
    const [current,usage]=await Promise.all([tx.get(record),tx.get(root.collection("private").doc("usage"))]);
    if(!current.exists)return;
    if(!revisionMatches(parsed.data.revision,Number(current.get("revision"))))throw new HttpsError("aborted","Record changed");
    logo=current.get("logoPath")??null;
    tx.delete(record);
    tx.set(root.collection("private").doc("usage"),{count:Math.max(0,Number(usage.get("count")??1)-1)},{merge:true});
  });
  await cleanup(logo);
  return {deleted:true};
});
export const setReminderPreferences=onCall(options,async request=>{
  const uid=requireUid(request.auth);
  const parsed=z.object({emailEnabled:z.boolean(),timeZone:z.string().max(100),locale:z.enum(["es","en"])}).strict().safeParse(request.data);
  if(!parsed.success)invalid();
  try{localDay(new Date(),parsed.data.timeZone);}catch{invalid();}
  const user=await getAuth().getUser(uid);
  if(parsed.data.emailEnabled&&(!user.emailVerified||!user.email))throw new HttpsError("failed-precondition","Verify your email");
  if(parsed.data.emailEnabled&&!emailDeliveryEnabled.value())throw new HttpsError("failed-precondition","Email provider not enabled");
  await db.doc(`users/${uid}/private/preferences`).set({...parsed.data,owner:uid,updatedAt:FieldValue.serverTimestamp()});
  return {saved:true};
});
export const enqueueReminders=onSchedule({
  region:"us-central1",schedule:"0 * * * *",timeZone:"Etc/UTC",maxInstances:1,timeoutSeconds:540,retryCount:3,
},async()=>{
  if(!emailDeliveryEnabled.value())return;
  let cursor:DocumentSnapshot|undefined;
  for(;;){
    let query=db.collectionGroup("private").where("emailEnabled","==",true).orderBy("__name__").limit(100);
    if(cursor)query=query.startAfter(cursor);
    const page=await query.get();
    if(page.empty)break;
    for(const preferences of page.docs){
      const p=preferences.data(),uid=p.owner as string;
      try{
        const {day,hour}=localDay(new Date(),p.timeZone);
        if(hour!==9)continue;
        const user=await getAuth().getUser(uid);
        if(!user.email||!user.emailVerified)continue;
        const subscriptions=await db.collection(`users/${uid}/subscriptions`).get();
        for(const document of subscriptions.docs){
          const parsed=subscriptionSchema.safeParse(Object.fromEntries(Object.entries(document.data()).filter(([k])=>k!=="updatedAt")));
          if(!parsed.success)continue;
          const s=parsed.data;
          for(const reminder of dueReminders(s,day)){
            const mailId=createHash("sha256").update(uid+":"+reminder.key).digest("hex");
            const mail=db.doc(`mail/${mailId}`);
            await db.runTransaction(async tx=>{
              const [existing,current,currentPreferences]=await Promise.all([tx.get(mail),tx.get(document.ref),tx.get(preferences.ref)]);
              if(existing.exists||!current.exists||current.get("revision")!==s.revision||currentPreferences.get("emailEnabled")!==true)return;
              const es=p.locale==="es";
              const kind=reminder.kind==="renewal"?(es?"renovación":"renewal"):reminder.kind==="trial"?(es?"fin de prueba":"trial end"):(es?"fin de plan":"plan end");
              const subject=es?`Ritmia · ${s.name}: ${kind} en ${reminder.leadDays} días`:`Ritmia · ${s.name}: ${kind} in ${reminder.leadDays} days`;
              const text=es?`${s.name}: ${kind} el ${reminder.target}. Revisa tu plan con el proveedor antes de esa fecha.`:
                `${s.name}: ${kind} on ${reminder.target}. Review your plan with the provider before that date.`;
              tx.create(mail,{owner:uid,to:[user.email],message:{subject,text:text+(s.cancelUrl?"\n"+s.cancelUrl:"")},
                reminderKey:reminder.key,createdAt:FieldValue.serverTimestamp(),expiresAt:Timestamp.fromMillis(Date.now()+90*86400000)});
            });
          }
        }
      }catch(error){logger.error("Reminder enqueue failed",{uid,error});throw error;}
    }
    cursor=page.docs.at(-1);
    if(page.size<100)break;
  }
});
// No client-callable upgrade endpoint. A verified store/Stripe webhook must own billing grants.
