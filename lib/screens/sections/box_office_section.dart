import 'package:flutter/material.dart';
import '../../models/news_article.dart';
import '../../screens/news_detail_page.dart';
import '../../widgets/news_card.dart';

typedef RefreshCallback = Future<void> Function();

class BoxOfficeSection extends StatelessWidget {
  final List<NewsArticle> articles;
  final RefreshCallback onRefresh;

  const BoxOfficeSection({
    super.key,
    required this.articles,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Box Office',
            style: TextStyle(
              color: Colors.pinkAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: articles.length,
              itemBuilder: (_, i) {
                final a = articles[i];
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
          ),
        ),
      ],
    );
  }
}
