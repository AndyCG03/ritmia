import {test,after} from "node:test";
import assert from "node:assert/strict";
import {initializeApp,deleteApp} from "firebase-admin/app";
import {getFirestore,Timestamp} from "firebase-admin/firestore";
import {randomBytes} from "node:crypto";
const project="demo-ritmia";
const app=initializeApp({projectId:project},"ritmia-integration"),db=getFirestore(app);
after(async()=>{await db.terminate();await deleteApp(app);});
function subscription(id:string){return {id,name:"Test",amountMinor:1299,currency:"USD",free:false,anchorDate:"2026-10-31",
  cycle:"monthly",color:4280828728,brandId:null,status:"active",category:"other",notes:"",logoPath:null,revision:0,
  reminderDays:[3,1],endsOn:null,trialEndsOn:null,cancelUrl:""};}
async function signup(){
  const response=await fetch("http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=test",{
    method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({email:randomBytes(8).toString("hex")+"@example.com",password:"Password123!",returnSecureToken:true})});
  assert.equal(response.status,200);return await response.json() as {idToken:string;localId:string};
}
async function call(name:string,data:unknown,token?:string){
  const response=await fetch(`http://127.0.0.1:5001/${project}/us-central1/${name}`,{method:"POST",
    headers:{"Content-Type":"application/json",...(token?{Authorization:"Bearer "+token}:{})},body:JSON.stringify({data})});
  const body=await response.json() as {result?:Record<string,unknown>;error?:{status:string}};
  return {status:response.status,body};
}
test("cloud quota is atomic, edits conflict, downgrade preserves records and rules deny bypass",async()=>{
  const user=await signup(),other=await signup();
  const ids=Array.from({length:7},()=>randomBytes(15).toString("base64url"));
  const responses=await Promise.all(ids.map(id=>call("saveSubscription",subscription(id),user.idToken)));
  assert.equal(responses.filter(r=>r.status===200).length,5);
  assert.equal(responses.filter(r=>r.body.error?.status==="RESOURCE_EXHAUSTED").length,2);
  assert.equal((await db.doc(`users/${user.localId}/private/usage`).get()).get("count"),5);
  const all=await db.collection(`users/${user.localId}/subscriptions`).get();
  const first=all.docs[0].data();
  assert.equal((await call("saveSubscription",{...first,updatedAt:undefined,notes:"stale",revision:0},user.idToken)).body.error?.status,"ABORTED");
  assert.equal((await call("saveSubscription",subscription(randomBytes(15).toString("base64url")))).status,401);
  const url=`http://127.0.0.1:8080/v1/projects/${project}/databases/(default)/documents/users/${user.localId}/subscriptions/${all.docs[0].id}`;
  assert.equal((await fetch(url,{headers:{Authorization:"Bearer "+other.idToken}})).status,403);
  assert.equal((await fetch(url,{method:"PATCH",headers:{Authorization:"Bearer "+user.idToken,"Content-Type":"application/json"},body:JSON.stringify({fields:{name:{stringValue:"bypass"}}})})).status,403);
  const billing=db.doc(`users/${user.localId}/private/billing`);
  await billing.set({plan:"pro",expiresAt:Timestamp.fromMillis(Date.now()+86400000)});
  const sixth=await call("saveSubscription",subscription(randomBytes(15).toString("base64url")),user.idToken);
  assert.equal(sixth.status,200);
  await billing.set({plan:"pro",expiresAt:Timestamp.fromMillis(Date.now()-1)});
  const extra=await call("saveSubscription",subscription(randomBytes(15).toString("base64url")),user.idToken);
  assert.equal(extra.body.error?.status,"RESOURCE_EXHAUSTED");
  const current={...first,updatedAt:undefined,notes:"after downgrade"};
  assert.equal((await call("saveSubscription",current,user.idToken)).status,200);
  assert.equal((await db.collection(`users/${user.localId}/subscriptions`).get()).size,6);
});
