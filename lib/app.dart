import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'presentation/pages/bookshelf/bookshelf_page.dart';
import 'presentation/pages/discover/discover_page.dart';
import 'presentation/pages/profile/profile_page.dart';
import 'presentation/pages/reader/reader_page.dart';
import 'presentation/pages/source/source_page.dart';
import 'presentation/pages/settings/settings_page.dart';
import 'presentation/pages/profile/backup_page.dart';

class YueduApp extends ConsumerStatefulWidget {
  const YueduApp({super.key});

  @override
  ConsumerState<YueduApp> createState() => _YueduAppState();
}

class _YueduAppState extends ConsumerState<YueduApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const BookshelfPage(),
    const DiscoverPage(),
    const SourcePage(),
    const ProfilePage(),
  ];

  final List<String> _pageTitles = [
    '书架',
    '发现',
    '书源',
    '我的',
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yuedu App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: Scaffold(
        appBar: AppBar(
          title: Text(_pageTitles[_currentIndex]),
        ),
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '书架',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '发现',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_open),
              label: '书源',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '我的',
            ),
          ],
        ),
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case Routes.reader:
            final bookId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ReaderPage(bookId: bookId),
            );
          case Routes.backup:
            return MaterialPageRoute(
              builder: (context) => const BackupPage(),
            );
          case Routes.settings:
            return MaterialPageRoute(
              builder: (context) => const SettingsPage(),
            );
          case Routes.source:
            return MaterialPageRoute(
              builder: (context) => const SourcePage(),
            );
          default:
            return null;
        }
      },
    );
  }
}