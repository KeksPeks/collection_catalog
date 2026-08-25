import 'package:shared_preferences/shared_preferences.dart';

/// Локальное хранилище прогресса геймификации.
/// Никакого сервера или авторизации для работы достижений не требуется.
class GamificationStore {
  static const _xpKey = 'gamification.xp';
  static const _unlockedKey = 'gamification.unlocked';

  Future<int> getXp() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_xpKey) ?? 0;
  }

  Future<Set<String>> getUnlocked() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(_unlockedKey) ?? const <String>[]).toSet();
  }

  Future<int> unlockIfNeeded(String id, int rewardXp) async {
    final preferences = await SharedPreferences.getInstance();
    final unlocked = (preferences.getStringList(_unlockedKey) ?? const <String>[]).toSet();
    if (!unlocked.add(id)) {
      return preferences.getInt(_xpKey) ?? 0;
    }
    final xp = (preferences.getInt(_xpKey) ?? 0) + rewardXp;
    await preferences.setStringList(_unlockedKey, unlocked.toList()..sort());
    await preferences.setInt(_xpKey, xp);
    return xp;
  }

  Future<void> reset() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_xpKey);
    await preferences.remove(_unlockedKey);
  }
}
