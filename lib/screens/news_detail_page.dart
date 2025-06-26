import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';
import '../theme/app_theme.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsArticle article;
  const NewsDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final service = NewsService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Article', style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontFamily: 'Poppins-Bold',
          color: Colors.pinkAccent,
          fontWeight: FontWeight.bold, // fallback if custom font doesn't load
        )),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
                    : Container(height: 200, color: Theme.of(context).colorScheme.onBackground),
                const SizedBox(height: 16),
                Text(
                  article.category.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  article.date,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Divider(
                  height: 32,
                  color: Theme.of(context).dividerColor,
                ),
                Html(
                  data: content,
                  style: {
                    "*": Style(
                      fontFamily: 'Poppins-Medium',
                      fontSize: FontSize(14.0),
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
