import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pinkvilla News',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
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
    await Future.delayed(const Duration(seconds: 1));
    allNews = List.generate(10, (index) {
      return {
        'node': {
          'imageUrl': '',
          'title': 'Placeholder News Title $index',
          'type': index.isEven ? 'Korean' : 'Lifestyle',
          'postDateFormat': 'April 30, 2025',
        }
      };
    });
    return allNews;
  }

  List<dynamic> get filteredNews {
    if (selectedCategory == 'All') return allNews;
    return allNews.where((item) => item['node']['type'] == selectedCategory).toList();
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
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.pinkAccent),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark, color: Colors.white),
              title: const Text('Bookmarks', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Add your navigation logic here
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Add your navigation logic here
                Navigator.pop(context);
              },
            ),
          ],
        ),
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
                    final item = filteredNews[index]['node'];
                    return NewsCard(
                      imageUrl: item['imageUrl'],
                      title: item['title'],
                      category: item['type'],
                      date: item['postDateFormat'],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NewsDetailPage(
                              title: item['title'],
                              imageUrl: item['imageUrl'],
                              category: item['type'],
                              date: item['postDateFormat'],
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
      'All',
      'Korean',
      'Lifestyle',
      'Web Stories',
      'Videos',
      'Trending',
      'TV',
      'Web series',
      'Fashion',
      'Entertainment'
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
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.imageUrl,
    required this.category,
    required this.title,
    required this.date,
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
                  Text(category,
                      style: const TextStyle(
                          color: Colors.orange, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(date,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class NewsDetailPage extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String category;
  final String date;

  const NewsDetailPage({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details', style: TextStyle(color: Colors.pinkAccent)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          imageUrl.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(imageUrl),
          )
              : Container(height: 200, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(category.toUpperCase(),
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const Divider(height: 32, color: Colors.grey),
          const Text(
            'This is a placeholder for the full article content. '
                'You can replace it with actual content from your API.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
