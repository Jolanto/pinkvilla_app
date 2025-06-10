  import 'dart:convert';
  import 'package:flutter/material.dart';
  import '../screens/news_detail_page.dart';
  import 'package:http/http.dart' as http;
  import '../models/news_article.dart';
  import '../models/news_article.dart';

  class NewsService {
    static const _listUrl =
        'https://englishapi.pinkvilla.com/app-api/v1/feed/site-feed.php?type=entertainment';
    static const _detailBase =
        'https://englishapi.pinkvilla.com/jsondata/v1/id/';

    Future<List<NewsArticle>> fetchNews() async {
      final res = await http.get(Uri.parse(_listUrl));
      if (res.statusCode != 200) {
        throw Exception('Failed to load news: ${res.statusCode}');
      }
      final list = json.decode(res.body) as List<dynamic>;
      return list.map((e) => NewsArticle.fromJson(e)).toList();
    }

    Future<List<NewsArticle>> fetchBoxOfficeNews() async {
      final response = await http.get(
        Uri.parse('https://englishapi.pinkvilla.com/app-api/v1/section.php?type=content_box-office'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load box office news');
      }

      final List<dynamic> list = json.decode(response.body);
      return list.map((e) => NewsArticle.fromJson(e)).toList();
    }

    Future<List<NewsArticle>> fetchLatestNews() async {
      final response = await http.get(
        Uri.parse('https://englishapi.pinkvilla.com/app-api/v1/latest_articles_widget'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load latest news');
      }

      final List<dynamic> list = json.decode(response.body);
      return list.map((e) => NewsArticle.fromJson(e)).toList();
    }


    Future<String> fetchArticleHtml(String articleId) async {
      final res = await http.get(Uri.parse('$_detailBase$articleId'));
      if (res.statusCode != 200) {
        throw Exception('Failed to load article: ${res.statusCode}');
      }
      final jsonData = json.decode(res.body);
      print(jsonData);
      final description = jsonData['description'] as List<dynamic>? ?? [];
      if (description.isEmpty) return '<p>No content available.</p>';

      final buffer = StringBuffer();
      for (final block in description) {
        switch (block['type']) {
          case 'text':
            buffer.writeln(
                block['value'] ?? block['html'] ?? block['content'] ?? '');
            break;
          case 'image':
            buffer.writeln(
                '<figure>'
                    '<img src="${block['src']}" alt="${block['caption'] ?? ''}"/>'
                    '<figcaption>${block['caption'] ?? ''}</figcaption>'
                    '</figure>');
            break;
          case 'social-media':
            final embedUrl = block['value'] ?? '';
            final platform = block['[platform]'];
            final rawHtml   = block['html'] as String? ?? '';

            if (rawHtml.trim().isNotEmpty) {
              buffer.writeln(rawHtml);
            } else if (platform == 'twitter') {
              buffer.writeln(
                  '<blockquote class="twitter-tweet"><a href="$embedUrl"></a></blockquote>');
            } else if (platform == 'instagram') {
              buffer.writeln(
                  '<blockquote class="instagram-media" data-instgrm-permalink="$embedUrl" '
                      'data-instgrm-version="14"></blockquote>');
            }
            break;
          default:
            break;
        }
      }
      return buffer.toString();
    }
  }
