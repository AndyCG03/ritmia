import 'subscription.dart';
String exportCsv(List<Subscription> items) {
  String cell(Object? value) {
    var text=value?.toString()??'';
    if(RegExp(r'^\s*[=+@-]').hasMatch(text))text="'$text";
    return '"${text.replaceAll('"','""')}"';
  }
  final rows=<List<Object?>>[
    ['id','name','amount_minor','currency','free','cycle','anchor_date','status','category','ends_on','trial_ends_on','reminder_days','cancel_url','notes','purchased_on'],
    for(final s in items)[s.id,s.name,s.amountMinor,s.currency,s.free,s.cycle.name,s.anchorDate,s.status.name,s.category.name,
      s.endsOn,s.trialEndsOn,s.reminderDays.join('|'),s.cancelUrl,s.notes,s.purchasedOn],
  ];
  return '\uFEFF${rows.map((r)=>r.map(cell).join(',')).join('\r\n')}\r\n';
}
