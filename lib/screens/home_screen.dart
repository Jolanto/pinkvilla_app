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
import '../theme/theme_controller.dart';

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
      _footerTabs = tabs;
      _isLoadingTabs = false;
    });
  }

  List<NewsArticle> get _filteredEnt =>
      _selectedCategory == 'All' ? _entAll : _entAll.where((n) => n.category == _selectedCategory).toList();


  Widget _buildTabContent(FooterTab tab) {
    final apiUrlToUse = _selectedApiUrl.isNotEmpty ? _selectedApiUrl : tab.apiUrl;

    return FutureBuilder<List<NewsArticle>>(
      future: _service.fetchArticlesFromUrl(apiUrlToUse),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}', style: TextStyle(color: Colors.red)));
        }

        final list = snap.data ?? [];

        return RefreshIndicator(
          onRefresh: () async {
            final fresh = await _service.fetchArticlesFromUrl(apiUrlToUse);
            setState(() => _futureArticles = Future.value(fresh));
          },
          child: ListView.builder(
            itemCount: list.length + 1, // +1 for the header
            itemBuilder: (_, i) {
              if (i == 0) {
                return HeaderNavigator(
                  tabs: _headerTabs,
                  selectedApiUrl: _selectedApiUrl,
                  onTabSelected: (tab) {
                    setState(() {
                      _selectedApiUrl = tab.apiUrl;
                      _futureArticles = _service.fetchArticlesByUrl(tab.apiUrl);
                    });
                  },
                );
              }

              final article = list[i - 1];
              return NewsCard(
                article: article,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NewsDetailPage(article: article)),
                ),
              );
            },
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.value == ThemeMode.dark;
    if (_isLoadingTabs || _isLoadingHeaderTabs) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentTab = _footerTabs[_currentIndex];
    final isSettings = false;

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
        'PINKVILLA',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontFamily: 'Poppins-Bold',
          color: Colors.pinkAccent,
          fontWeight: FontWeight.bold, // fallback if custom font doesn't load
        ),
      ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.pinkAccent),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.pinkAccent),
              child: const Center(
                child: Text(
                  'PINKVILLA Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.view_list),
              title: const Text('Categories'),
              children: _headerTabs.map((tab) {
                return ListTile(
                  title: Text(tab.name),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedApiUrl = tab.apiUrl;
                      _futureArticles = _service.fetchArticlesByUrl(tab.apiUrl);
                    });
                  },
                );
              }).toList(),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsPage(
                      isDarkMode: isDark,
                      onToggleTheme: (isDarkMode) {
                        themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
                      },
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: "PINKVILLA",
                  applicationVersion: "1.0.0",
                  applicationLegalese: "© 2025 Pinkvilla",
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (!isSettings && _headerTabs.isNotEmpty)
            Expanded(
              child: _buildTabContent(currentTab),
            ),
          if (isSettings)
            Expanded(
              child: SettingsPage(
                isDarkMode: themeNotifier.value == ThemeMode.dark,
                onToggleTheme: (isDark) {
                  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
                },
              ),
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
        unselectedItemColor: Theme.of(context).colorScheme.onBackground,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,

        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins-SemiBold',
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
        ),

        items: List.generate(_footerTabs.length, (i) {
          final tab = _footerTabs[i];
          final imageUrl = tab.imageUrl;

          return BottomNavigationBarItem(
            icon: Image.network(
              imageUrl,
              width: 24,
              height: 24,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
            ),
            label: tab.title,
          );
        }),
      ),

    );
  }
}