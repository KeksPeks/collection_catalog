import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lib/features/gamification/data/gamification_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('локально сохраняет XP только один раз для одного достижения', () async {
    final store = GamificationStore();

    expect(await store.getXp(), 0);
    expect(await store.unlockIfNeeded('first_item', 25), 25);
    expect(await store.unlockIfNeeded('first_item', 25), 25);
    expect(await store.getUnlocked(), {'first_item'});
  });

  test('локальный прогресс можно сбросить', () async {
    final store = GamificationStore();
    await store.unlockIfNeeded('test', 100);

    await store.reset();

    expect(await store.getXp(), 0);
    expect(await store.getUnlocked(), isEmpty);
  });
}
