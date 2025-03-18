class WorkoutArticle {
  String postTitle;
  String authorName;
  String avatarURL;
  DateTime postDate;
  String postURL;
  String postExcerpt;
  int likeCount;
  int commentCount;
  List<String> postTag;
  String thumbnailURL;

  WorkoutArticle({
    required this.postTitle,
    required this.authorName,
    required this.avatarURL,
    required this.postDate,
    required this.postURL,
    required this.postExcerpt,
    required this.likeCount,
    required this.commentCount,
    required this.postTag,
    required this.thumbnailURL,
  });
  factory WorkoutArticle.fromMap(Map<String, dynamic> post) {
    return WorkoutArticle(
      postTitle: post['title'] ?? 'No Title',
      authorName: post['author']?['name'] ?? 'Unknown Author',
      avatarURL: post['author']?['avatar_URL'] ?? '',
      postDate: DateTime.tryParse(post['date'] ?? '') ?? DateTime.now(),
      postURL: post['URL'] ?? '',
      postExcerpt: post['excerpt'] ?? '',
      likeCount: post['like_count'] ?? 0,
      commentCount: post['comment_count'] ?? 0,
      postTag: (post['tags'] as Map<String, dynamic>?)?.keys.toList() ?? [],
      thumbnailURL: post['featured_image'] ?? '',
    );
  }
}