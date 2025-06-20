  import 'dart:convert';
  import 'package:flutter/material.dart';
  import '../screens/news_detail_page.dart';
  import 'package:http/http.dart' as http;
  import '../models/news_article.dart';
  import '../models/footer_tab.dart';
  import '../models/header_tab.dart';


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

    Future<List<FooterTab>> fetchFooterTabs() async {
      final res = await http.get(
        Uri.parse("https://fastapi.pinkvilla.com/v1/section/footer-menu"),
      );

      if (res.statusCode != 200) {
        throw Exception("Failed to load footer tabs");
      }

      final jsonData = json.decode(res.body);

      // Make sure 'data' and 'content' exist and are lists
      final content = (jsonData['data']?['content'] ?? []) as List<dynamic>;

      return content
          .map((item) => FooterTab.fromJson(item as Map<String, dynamic>))
          .toList();
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

    Future<List<NewsArticle>> fetchArticlesFromUrl(String url) async {
      if (url.isEmpty) return [];

      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) {
        throw Exception('Failed to load articles from $url');
      }

      final data = json.decode(res.body);
      final rawList = data is List
          ? data
          : (data['nodes'] ?? data['data'] ?? data) as List<dynamic>?;

      if (rawList == null) return [];

      return rawList.map((node) => NewsArticle.fromJson(node)).toList();
    }

    Future<List<HeaderTab>> fetchHeaderTabs() async {
      final res = await http.get(
        Uri.parse('https://fastapi.pinkvilla.com/v1/section/header-menu'),
      );

      if (res.statusCode != 200) {
        throw Exception('Failed to load header tabs');
      }

      final jsonData = json.decode(res.body);
      final content = jsonData['data']['content'] as List;

      return content.map((item) => HeaderTab.fromJson(item)).toList();
    }



    Future<List<NewsArticle>> fetchArticlesByUrl(String apiUrl) async {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((item) => NewsArticle.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load articles from $apiUrl');
      }
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
