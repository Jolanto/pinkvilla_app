import 'package:flutter/material.dart';
import '../models/news_article.dart';
import '../models/footer_tab.dart';
import '../models/header_tab.dart';
import '../services/news_service.dart';
import '../widgets/news_card.dart';
import '../widgets/header_navigator.dart';
import '../screens/news_detail_page.dart';
import 'settings_page.dart';
import 'sections/entertainment_section.dart';
import 'sections/box_office_section.dart';
import 'sections/latest_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _service = NewsService();

  late Future<List<NewsArticle>> _entNewsF;
  late Future<List<NewsArticle>> _boxOfficeF;
  late Future<List<NewsArticle>> _latestNewsF;

  String _selectedCategory = 'All';
  List<NewsArticle> _entAll = [];
  List<FooterTab> _footerTabs = [];
  bool _isLoadingTabs = true;
  List<HeaderTab> _headerTabs = [];
  String _selectedApiUrl = '';
  late Future<List<NewsArticle>> _futureArticles;
  bool _isLoadingHeaderTabs = true;

  @override
  void initState() {
    super.initState();
    _loadInitialTabs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTabs();
      _entNewsF = _service.fetchNews();
      _boxOfficeF = _service.fetchBoxOfficeNews();
      _latestNewsF = _service.fetchLatestNews();
    });
  }

  Future<void> _refreshEntertainment() async {
    final fresh = await _service.fetchNews();
    setState(() {
      _entAll = fresh;
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

  void _initTabs() async {
    final tabs = await _service.fetchHeaderTabs();
    if (tabs.isNotEmpty) {
      setState(() {
        _headerTabs = tabs;
        _selectedApiUrl = tabs.first.apiUrl;
        _futureArticles = _service.fetchArticlesByUrl(_selectedApiUrl);
        _isLoadingHeaderTabs = false;
      });
    } else {
      setState(() => _isLoadingHeaderTabs = false);
    }
  }

  Future<void> _loadInitialTabs() async {
    final tabs = await _service.fetchFooterTabs();
    setState(() {
      _footerTabs = [...tabs, FooterTab(id: '0', title: "Settings", apiUrl: "")];
      _isLoadingTabs = false;
    });
  }

  List<NewsArticle> get _filteredEnt =>
      _selectedCategory == 'All' ? _entAll : _entAll.where((n) => n.category == _selectedCategory).toList();

  final List<IconData> _tabIcons = [
    Icons.article,
    Icons.fiber_new,
    Icons.tv,
    Icons.movie,
    Icons.settings,
  ];

  IconData _getIcon(int index) => index < _tabIcons.length ? _tabIcons[index] : Icons.article;

  Widget _buildTabContent(FooterTab tab) {
    final apiUrlToUse = _selectedApiUrl.isNotEmpty ? _selectedApiUrl : tab.apiUrl;
    return FutureBuilder<List<NewsArticle>>(
      future: _service.fetchArticlesFromUrl(apiUrlToUse),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snap.hasError) {
          return Center(child: Text('Error: \${snap.error}', style: TextStyle(color: Colors.red)));
        }

        final list = snap.data ?? [];
        return RefreshIndicator(
          onRefresh: () async {
            final fresh = await _service.fetchArticlesFromUrl(apiUrlToUse);
            setState(() => _futureArticles = Future.value(fresh));
          },
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) => NewsCard(
              article: list[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NewsDetailPage(article: list[i])),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingTabs || _isLoadingHeaderTabs) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentTab = _footerTabs[_currentIndex];
    final isSettings = currentTab.title == 'Settings';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('PINKVILLA', style: TextStyle(color: Colors.pinkAccent)),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          if (!isSettings && _headerTabs.isNotEmpty)
            HeaderNavigator(
              tabs: _headerTabs,
              selectedApiUrl: _selectedApiUrl,
              onTabSelected: (tab) {
                setState(() {
                  _selectedApiUrl = tab.apiUrl;
                  _futureArticles = _service.fetchArticlesByUrl(tab.apiUrl);
                });
              },
            ),
          Expanded(
            child: isSettings
                ? const SettingsPage()
                : _buildTabContent(currentTab),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() {
          _currentIndex = i;
          _selectedApiUrl = _footerTabs[i].apiUrl;
        }),
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        items: List.generate(_footerTabs.length, (i) {
          final tab = _footerTabs[i];
          return BottomNavigationBarItem(
            icon: Icon(_getIcon(i)),
            label: tab.title,
          );
        }),
      ),
    );
  }
}
