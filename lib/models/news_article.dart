class NewsArticle {
  final String id;
  final String title;
  final String imageUrl;
  final String category;
  final String date;

  NewsArticle({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.date,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) => NewsArticle(
    id:     json['nid'].toString(),
    title:  json['title'] ?? 'No Title',
    imageUrl: json['imageUrl'] ?? json['featuredImage'] ?? '',
    category: json['type'] ?? 'Unknown',
    date:   json['postDateFormat'] ?? '',
  );
}
