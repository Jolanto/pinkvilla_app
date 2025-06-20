class HeaderTab {
  final int id;
  final String name;
  final String apiUrl;

  HeaderTab({required this.id, required this.name, required this.apiUrl});

  factory HeaderTab.fromJson(Map<String, dynamic> json) {
    return HeaderTab(
      id: json['id'],
      name: json['title'],
      apiUrl: json['api_url'] ?? '',
    );
  }
}
