import {test} from "node:test";
import assert from "node:assert/strict";
import {subscriptionSchema,occurrence,dueReminders,canCreate,localDay,revisionMatches,Subscription} from "./domain.js";
const sample:Subscription={id:"abcdefghijklmnopqrst",name:"Spotify",amountMinor:1299,currency:"USD",free:false,
  anchorDate:"2024-01-31",cycle:"monthly",color:4280828728,brandId:"spotify",status:"active",category:"entertainment",
  notes:"",logoPath:null,revision:0,reminderDays:[3,1],endsOn:null,trialEndsOn:null,cancelUrl:"https://spotify.com/account"};
test("month ends and leap-year anchor",()=>{
  assert.equal(occurrence(sample,1),"2024-02-29");assert.equal(occurrence(sample,2),"2024-03-31");
  assert.equal(occurrence({...sample,anchorDate:"2024-02-29",cycle:"yearly"},4),"2028-02-29");
});
test("invalid dates, fractional amounts and unsafe URLs rejected",()=>{
  for(const patch of [{anchorDate:"2025-02-29"},{amountMinor:1.2},{free:true},{cancelUrl:"javascript:alert(1)"},{reminderDays:[1,1]},{endsOn:"2023-01-01"}]){
    assert.equal(subscriptionSchema.safeParse({...sample,...patch}).success,false);
  }
});
test("free versus pro and revisions",()=>{
  assert.equal(canCreate(4,false),true);assert.equal(canCreate(5,false),false);
  assert.equal(canCreate(600,true),true);assert.equal(revisionMatches(1,2),false);
});
test("reminders have stable keys and stop at end dates",()=>{
  const s={...sample,anchorDate:"2026-10-20",endsOn:"2026-11-20",trialEndsOn:"2026-10-19"};
  assert.equal(dueReminders(s,"2026-10-17")[0].target,"2026-10-20");
  assert.equal(dueReminders(s,"2026-10-18")[0].kind,"trial");
  assert.equal(dueReminders(s,"2026-11-17").some(r=>r.kind==="renewal"),false);
  assert.equal(dueReminders({...s,status:"paused"},"2026-10-17").length,0);
});
test("timezone calculation uses user's civil date",()=>{
  assert.deepEqual(localDay(new Date("2026-10-16T13:00:00Z"),"America/Havana"),{day:"2026-10-16",hour:9});
  assert.deepEqual(localDay(new Date("2026-10-16T00:30:00Z"),"America/Los_Angeles"),{day:"2026-10-15",hour:17});
});
