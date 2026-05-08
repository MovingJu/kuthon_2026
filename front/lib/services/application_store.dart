class AppliedPost {
  final String id;
  final String title;
  final String subtitle;
  final String reward;
  final String deadline;
  final String imageAsset;

  const AppliedPost({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.deadline,
    required this.imageAsset,
  });
}

class ApplicationStore {
  ApplicationStore._();
  static final ApplicationStore instance = ApplicationStore._();

  final List<AppliedPost> _applied = [];

  List<AppliedPost> get applied => List.unmodifiable(_applied);

  bool isApplied(String id) => _applied.any((p) => p.id == id);

  void apply(AppliedPost post) {
    if (!isApplied(post.id)) _applied.add(post);
  }
}
