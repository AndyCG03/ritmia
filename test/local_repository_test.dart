import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ritmia/data/local_repository.dart';
import 'package:ritmia/domain/repositories.dart';
import 'package:ritmia/domain/subscription.dart';
Subscription item(int index,{SubscriptionStatus status=SubscriptionStatus.active})=>Subscription(
  id:index.toString().padLeft(20,'0'),name:'Service $index',amountMinor:1000,currency:'USD',free:false,anchorDate:'2026-10-16',
  cycle:BillingCycle.monthly,color:0xFF282338,status:status);
void main(){
  late LocalRepository repo;
  setUp(()async{SharedPreferences.setMockInitialValues({});repo=LocalRepository(await SharedPreferences.getInstance());});
  tearDown(()=>repo.dispose());
  test('writes are persisted sequentially and allow unlimited records',()async{
    final outcomes=await Future.wait(List.generate(8,(i)=>repo.save(item(i)).then<Object>((s)=>s).catchError((Object e)=>e)));
    expect(outcomes.whereType<Subscription>().length,8);
    expect((await repo.watch().first).length,8);
  });
  test('archived records persist and deletion removes an item',()async{
    final saved=await Future.wait(List.generate(5,(i)=>repo.save(item(i,status:SubscriptionStatus.archived))));
    final extra=await repo.save(item(6));
    expect((await repo.watch().first).length,6);
    await repo.delete(saved.first);
    expect((await repo.watch().first).length,5);
  });
  test('edits check revision and persist optimized logos',()async{
    final saved=await repo.save(item(1));
    await expectLater(repo.save(item(1)),throwsA(isA<AppFailure>()));
    final updated=await repo.setLogo(saved,Uint8List.fromList([1,2,3]));
    expect(await repo.loadLogo(updated),[1,2,3]);expect(updated.revision,2);
  });
  test('sequential writes continue to succeed',()async{
    final saved=await Future.wait(List.generate(5,(i)=>repo.save(item(i))));
    await repo.save(item(6));
    await repo.delete(saved.last);await repo.save(item(7));expect((await repo.watch().first).length,6);
  });
}
