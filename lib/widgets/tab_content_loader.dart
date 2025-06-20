import 'package:flutter/material.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';
import '../widgets/news_card.dart';
import '../screens/news_detail_page.dart';

class TabContentLoader extends StatelessWidget {
  final String apiUrl;

  const TabContentLoader({super.key, required this.apiUrl});

  @override
  Widget build(BuildContext context) {
    final _service = NewsService();

    return FutureBuilder<List<NewsArticle>>(
      future: _service.fetchArticlesFromUrl(apiUrl),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }

        final list = snap.data ?? [];

        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final a = list[i];
              return NewsCard(
                article: a,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewsDetailPage(article: a),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
