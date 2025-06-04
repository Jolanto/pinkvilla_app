import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'dart:math';
import 'settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Pinkvilla News',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: mode,
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> newsList;
  String selectedCategory = 'All';
  List<dynamic> allNews = [];

  @override
  void initState() {
    super.initState();
    newsList = fetchNews();
  }

  Future<List<dynamic>> fetchNews() async {
    const apiUrl = 'https://englishapi.pinkvilla.com/app-api/v1/feed/site-feed.php?type=entertainment';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        allNews = jsonData;
        return allNews;
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching news: $e');
      throw Exception('Error fetching news: $e');
    }
  }

  List<dynamic> get filteredNews {
    if (selectedCategory == 'All') return allNews;
    return allNews.where((item) => item['type'] == selectedCategory).toList();
  }

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('PINKVILLA', style: TextStyle(color: Colors.pinkAccent)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.pinkAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: newsList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategorySelector(
                selectedCategory: selectedCategory,
                onCategorySelected: onCategorySelected,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Top Stories',
                  style: TextStyle(
                    color: Colors.pinkAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredNews.length,
                  itemBuilder: (context, index) {
                    final item = filteredNews[index];
                    final imageUrl = item['imageUrl'] ?? '';
                    final title = item['title'] ?? 'No Title';
                    final category = item['type'] ?? 'Unknown';
                    final date = item['postDateFormat'] ?? '';
                    final articleId = item['nid']?.toString() ?? '';

                    return NewsCard(
                      imageUrl: imageUrl,
                      title: title,
                      category: category,
                      date: date,
                      articleId: articleId,
                      onTap: () {
                        print('🧭 Navigating to articleId: $articleId');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NewsDetailPage(
                              articleId: articleId,
                              title: title,
                              imageUrl: imageUrl,
                              category: category,
                              date: date,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final void Function(String) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All', 'Korean', 'Lifestyle', 'Web Stories',
      'Videos', 'Trending', 'TV', 'Web series',
      'Fashion', 'Entertainment'
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return GestureDetector(
            onTap: () => onCategorySelected(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.pinkAccent : Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[300],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final String imageUrl;
  final String category;
  final String title;
  final String date;
  final String articleId;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.imageUrl,
    required this.category,
    required this.title,
    required this.date,
    required this.articleId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.grey[900],
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            )
                : Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Icon(Icons.image_not_supported, color: Colors.white60, size: 40),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String> fetchArticleContent(String articleId) async {
  final url = 'https://englishapi.pinkvilla.com/jsondata/v1/id/$articleId';
  print('Fetching article: $url');

  try {
    final response = await http.get(Uri.parse(url));
    print('HTTP status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('Article fetched successfully');

      final descriptionList = jsonData['description'] as List<dynamic>?;
      if (descriptionList == null || descriptionList.isEmpty) {
        print('No description found in the article');
        return '<p>No content available.</p>';
      }

      final buffer = StringBuffer();
      for (final block in descriptionList) {
        if (block['type'] == 'text' && block['newContent'] != null) {
          buffer.writeln(block['newContent']);
        } else if (block['type'] == 'image' && block['src'] != null) {
          final caption = block['caption'] ?? '';
          buffer.writeln(
              '<figure><img src="${block['src']}" alt="$caption"/><figcaption>$caption</figcaption></figure>');
        }
      }

      final finalHtml = buffer.toString();
      print('Final HTML content length: ${finalHtml.length}');
      return finalHtml.isNotEmpty ? finalHtml : '<p>No content available.</p>';
    } else {
      throw Exception('Failed to load article content (status ${response.statusCode})');
    }
  } catch (e) {
    print('Error fetching article: $e');
    return '<p>Error loading article content.</p>';
  }
}


class NewsDetailPage extends StatelessWidget {
  final String articleId;
  final String title;
  final String imageUrl;
  final String category;
  final String date;

  const NewsDetailPage({
    Key? key,
    required this.articleId,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('NewsDetailPage opened for articleId: $articleId');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Article', style: TextStyle(color: Colors.pinkAccent)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<String>(
        future: fetchArticleContent(articleId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading article content'));
          } else {
            final content = snapshot.data ?? '';
            print('Content: ${content.substring(0, min(300, content.length))}');
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imageUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(imageUrl),
                  )
                      : Container(height: 200, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text(category.toUpperCase(), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const Divider(height: 32, color: Colors.grey),
                  Html(data: content),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
