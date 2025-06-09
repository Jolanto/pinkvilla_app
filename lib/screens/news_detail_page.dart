import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsArticle article;
  const NewsDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final service = NewsService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Article',
            style: TextStyle(color: Colors.pinkAccent)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<String>(
        future: service.fetchArticleHtml(article.id),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snap.hasError) {
            return const Center(child: Text('Error loading content'));
          }
          final content = snap.data ?? '';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                article.imageUrl.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(article.imageUrl),
                )
                    : Container(height: 200, color: Colors.grey[700]),
                const SizedBox(height: 16),
                Text(article.category.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(article.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(article.date,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const Divider(height: 32, color: Colors.grey),
                Html(data: content),
              ],
            ),
          );
        },
      ),
    );
  }
}
