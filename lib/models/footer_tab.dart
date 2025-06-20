class FooterTab {
  final String id;
  final String title;
  final String apiUrl;
  final String imageUrl;

  FooterTab({
    required this.id,
    required this.title,
    required this.apiUrl,
    required this.imageUrl
  });

  factory FooterTab.fromJson(Map<String, dynamic> json) {
    return FooterTab(
      id: json['id'].toString(),
      title: json['title'],
      apiUrl: json['api_url'],
      imageUrl: json['image_url_light'],
    );
  }
}
