class FooterTab {
  final String id;
  final String title;
  final String apiUrl;

  FooterTab({
    required this.id,
    required this.title,
    required this.apiUrl,
  });

  factory FooterTab.fromJson(Map<String, dynamic> json) {
    return FooterTab(
      id: json['id'].toString(),
      title: json['title'],
      apiUrl: json['api_url'],
    );
  }
}
