class NewsArticle {
  final String id;
  final String title;
  final String category;
  final String url;
  final String imageUrl;
  final String date;

  NewsArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.url,
    required this.imageUrl,
    required this.date,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['nid'].toString() ?? '',
      title: json['title'] ?? '',
      category: json['type'] ?? '',
      url: 'https://www.pinkvilla.com${json['path'] ?? ''}',
      imageUrl: json['imageUrl'] ?? '',
      date: json['postDateFormat'] ?? '',
    );
  }
}
