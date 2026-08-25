/// Описание локального достижения коллекционера.
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int target;
  final int rewardXp;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
    required this.rewardXp,
  });
}
