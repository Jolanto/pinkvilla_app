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

  // ──────────────────────────── DATA ────────────────────────────
  final _service = NewsService();

  late Future<List<NewsArticle>> _entNewsF;      // Entertainment
  late Future<List<NewsArticle>> _boxOfficeF;    // Box Office
  late Future<List<NewsArticle>> _latestNewsF;   // Latest

  String _selectedCategory = 'All';
  List<NewsArticle> _entAll = [];

  // ──────────────────────────── INIT ────────────────────────────
  @override
  void initState() {
    super.initState();
    _entNewsF   = _service.fetchNews();
    _boxOfficeF = _service.fetchBoxOfficeNews();
    _latestNewsF = _service.fetchLatestNews();
  }

  // ──────────────────────────── REFRESH HELPERS ────────────────────────────
  Future<void> _refreshEntertainment() async {
    final fresh = await _service.fetchNews();
    setState(() {
      _entAll   = fresh;
      _entNewsF = Future.value(fresh);
    });
  }

  Future<void> _refreshBoxOffice() async {
    final fresh = await _service.fetchBoxOfficeNews();
    setState(() => _boxOfficeF = Future.value(fresh));
  }

  Future<void> _refreshLatest() async {
    final fresh = await _service.fetchLatestNews();
    setState(() => _latestNewsF = Future.value(fresh));
  }

  // ──────────────────────────── FILTER ────────────────────────────
  List<NewsArticle> get _filteredEnt =>
      _selectedCategory == 'All'
          ? _entAll
          : _entAll.where((n) => n.category == _selectedCategory).toList();

  // ──────────────────────────── PAGES LIST ────────────────────────────
  List<Widget> get _pages => [
    _buildEntertainmentPage(),
    _buildBoxOfficePage(),
    _buildLatestPage(),
    const SettingsPage(),
  ];

  // ──────────────────────────── ENTERTAINMENT ────────────────────────────
  Widget _buildEntertainmentPage() => FutureBuilder<List<NewsArticle>>(
    future: _entNewsF,
    builder: (_, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snap.hasError) {
        return Center(child: Text('Error: ${snap.error}'));
      }
      _entAll = snap.data ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategorySelector(
            selected: _selectedCategory,
            onChanged: (c) => setState(() => _selectedCategory = c),
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
              onRefresh: _refreshEntertainment,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _filteredEnt.length,
                itemBuilder: (_, i) {
                  final a = _filteredEnt[i];
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
    },
  );

  Widget _buildBoxOfficePage() => FutureBuilder<List<NewsArticle>>(
    future: _boxOfficeF,
    builder: (_, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snap.hasError) {
        return Center(child: Text('Error: ${snap.error}'));
      }
      final list = snap.data ?? [];

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
              onRefresh: _refreshBoxOffice,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
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
            ),
          ),
        ],
      );
    },
  );

  // ──────────────────────────── LATEST ────────────────────────────
  Widget _buildLatestPage() => FutureBuilder<List<NewsArticle>>(
    future: _latestNewsF,
    builder: (_, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snap.hasError) {
        return Center(child: Text('Error: ${snap.error}'));
      }
      final list = snap.data ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Latest',
              style: TextStyle(
                color: Colors.pinkAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshLatest,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
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
            ),
          ),
        ],
      );
    },
  );

  // ──────────────────────────── BUILD ────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'PINKVILLA',
          style: TextStyle(color: Colors.pinkAccent),
        ),
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
            label: 'Entertainment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_movies),
            label: 'Box Office',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fiber_new),
            label: 'Latest',
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
