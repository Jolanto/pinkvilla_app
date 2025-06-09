import 'package:flutter/material.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';
import '../widgets/category_selector.dart';
import '../widgets/news_card.dart';
import '../screens/news_detail_page.dart';
import 'settings_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late Future<List<NewsArticle>> _newsList;
  final _service = NewsService();
  String _selectedCategory = 'All';
  List<NewsArticle> _allNews = [];

  @override
  void initState() {
    super.initState();
    _newsList = _service.fetchNews();
  }

  Future<void> _refreshNews() async {
    final freshNews = await _service.fetchNews();
    setState(() {
      _allNews = freshNews;
      _newsList = Future.value(freshNews);
    });
  }

  void _onCategorySelected(String category) =>
      setState(() => _selectedCategory = category);

  List<NewsArticle> get _filteredNews =>
      _selectedCategory == 'All'
          ? _allNews
          : _allNews.where((n) => n.category == _selectedCategory).toList();

  List<Widget> get _pages => [
    _buildNewsPage(),
    const SettingsPage(),
  ];

  Widget _buildNewsPage() => FutureBuilder<List<NewsArticle>>(
    future: _newsList,
    builder: (_, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snap.hasError) {
        return Center(child: Text('Error: ${snap.error}'));
      }
      _allNews = snap.data ?? [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategorySelector(
            selected: _selectedCategory,
            onChanged: _onCategorySelected,
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
            child: RefreshIndicator(
              onRefresh: _refreshNews,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _filteredNews.length,
                itemBuilder: (_, i) {
                  final article = _filteredNews[i];
                  return NewsCard(
                    article: article,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewsDetailPage(article: article),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('PINKVILLA',
            style: TextStyle(color: Colors.pinkAccent)),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),

      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
