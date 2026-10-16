import {z} from "zod";
export const dateSchema=z.string().regex(/^\d{4}-\d{2}-\d{2}$/).refine(v=>{
  const d=new Date(v+"T00:00:00Z");return !Number.isNaN(d.valueOf())&&d.toISOString().slice(0,10)===v&&v>="2000-01-01"&&v<="2100-12-31";
});
export const subscriptionSchema=z.object({
  id:z.string().regex(/^[a-zA-Z0-9_-]{20}$/),name:z.string().trim().min(1).max(80),
  amountMinor:z.number().int().min(0).max(99999999999),
  currency:z.enum(["USD","EUR","MXN","CUP","GBP","CAD","JPY"]),free:z.boolean(),
  anchorDate:dateSchema,cycle:z.enum(["weekly","monthly","quarterly","yearly"]),
  color:z.number().int().min(0).max(4294967295),brandId:z.string().regex(/^[a-z0-9]+$/).max(80).nullable(),
  status:z.enum(["active","paused","archived"]),category:z.enum(["entertainment","productivity","storage","education","health","utilities","other"]),
  notes:z.string().trim().max(1000),logoPath:z.string().max(240).nullable(),revision:z.number().int().min(0),
  reminderDays:z.array(z.union([z.literal(1),z.literal(3),z.literal(7),z.literal(14)])).max(4)
    .refine(v=>new Set(v).size===v.length),
  endsOn:dateSchema.nullable(),trialEndsOn:dateSchema.nullable(),
  cancelUrl:z.union([z.literal(""),z.string().url().max(500).refine(v=>new URL(v).protocol==="https:")]),
}).strict().refine(s=>s.free?s.amountMinor===0:s.amountMinor>0)
  .refine(s=>s.endsOn===null||s.endsOn>s.anchorDate);
export type Subscription=z.infer<typeof subscriptionSchema>;
export function canCreate(count:number,pro:boolean):boolean{return pro||count<5;}
export function revisionMatches(expected:number,actual:number):boolean{return expected===actual;}
export function occurrence(s:Subscription,index:number):string{
  const anchor=new Date(s.anchorDate+"T00:00:00Z");
  if(s.cycle==="weekly"){anchor.setUTCDate(anchor.getUTCDate()+7*index);return anchor.toISOString().slice(0,10);}
  const step={monthly:1,quarterly:3,yearly:12}[s.cycle];
  const first=new Date(Date.UTC(anchor.getUTCFullYear(),anchor.getUTCMonth()+step*index,1));
  const last=new Date(Date.UTC(first.getUTCFullYear(),first.getUTCMonth()+1,0)).getUTCDate();
  return new Date(Date.UTC(first.getUTCFullYear(),first.getUTCMonth(),Math.min(anchor.getUTCDate(),last))).toISOString().slice(0,10);
}
export function addDays(date:string,days:number):string{
  const d=new Date(date+"T00:00:00Z");d.setUTCDate(d.getUTCDate()+days);return d.toISOString().slice(0,10);
}
export type Reminder={kind:"renewal"|"trial"|"ending";target:string;leadDays:number;key:string};
export function dueReminders(s:Subscription,today:string):Reminder[]{
  if(s.status!=="active")return [];
  const targets:{kind:Reminder["kind"];target:string}[]=[];
  const anchor=new Date(s.anchorDate+"T00:00:00Z"),now=new Date(today+"T00:00:00Z");
  const months=(now.getUTCFullYear()-anchor.getUTCFullYear())*12+now.getUTCMonth()-anchor.getUTCMonth();
  let index=Math.max(0,s.cycle==="weekly"?Math.floor((now.valueOf()-anchor.valueOf())/604800000)-2:
    Math.floor(months/({monthly:1,quarterly:3,yearly:12}[s.cycle]))-1);
  for(;;index++){
    const target=occurrence(s,index);
    if(target>addDays(today,14)||(s.endsOn!==null&&target>=s.endsOn))break;
    if(target>=today)targets.push({kind:"renewal",target});
  }
  if(s.trialEndsOn)targets.push({kind:"trial",target:s.trialEndsOn});
  if(s.endsOn)targets.push({kind:"ending",target:s.endsOn});
  const reminders:Reminder[]=[];
  for(const {kind,target} of targets){
    for(const leadDays of new Set(s.reminderDays)){
      if(addDays(target,-leadDays)===today)reminders.push({kind,target,leadDays,key:`${s.id}:${kind}:${target}:${leadDays}`});
    }
  }
  return reminders;
}
export function localDay(now:Date,timeZone:string):{day:string;hour:number}{
  const parts=new Intl.DateTimeFormat("en-CA",{timeZone,year:"numeric",month:"2-digit",day:"2-digit",hour:"2-digit",hourCycle:"h23"})
    .formatToParts(now);
  const value=(type:string)=>parts.find(p=>p.type===type)!.value;
  return {day:`${value("year")}-${value("month")}-${value("day")}`,hour:Number(value("hour"))};
}
