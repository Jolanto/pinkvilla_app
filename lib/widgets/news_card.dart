import 'package:flutter/material.dart';
import '../models/news_article.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback? onTap;

  const NewsCard({super.key, required this.article, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.grey[900],
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            article.imageUrl.isNotEmpty
                ? Image.network(article.imageUrl)
                : Container(height: 180, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.category.toUpperCase(),
                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(article.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins-Bold')),
                  const SizedBox(height: 8),
                  Text(article.date,
                      style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Poppins-Regular')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
