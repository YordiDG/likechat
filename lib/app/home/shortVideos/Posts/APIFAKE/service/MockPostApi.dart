
class MockPostApi {
  final int id;
  final String description;
  final List<String> imagePaths;
  final DateTime createdAt;
  final String userName;
  final String userAvatar;
  bool isLiked;
  int likeCount;
  int currentIndex;

  MockPostApi({
    required this.id,
    required this.description,
    required this.imagePaths,
    required this.createdAt,
    required this.userName,
    this.userAvatar = 'lib/assets/avatar.png',
    this.isLiked = false,
    this.likeCount = 0,
    this.currentIndex = 0,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}sem';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}m';
    } else {
      return '${(difference.inDays / 365).floor()}a';
    }
  }
}

