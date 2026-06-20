import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/pages/bookshelf/bookshelf_page.dart';
import '../presentation/pages/reader/reader_page.dart';
import '../presentation/pages/reader/pdf_reader_page.dart';
import '../presentation/pages/discover/discover_page.dart';
import '../presentation/pages/source/source_page.dart';
import '../presentation/pages/profile/profile_page.dart';
import '../presentation/pages/profile/backup_page.dart';

/// 路由路径常量
class AppRoutes {
  AppRoutes._();

  // 路由路径
  static const String bookshelf = '/bookshelf';
  static const String discover = '/discover';
  static const String source = '/source';
  static const String profile = '/profile';
  static const String reader = '/reader';
  static const String bookDetail = '/book-detail';
  static const String pdfReader = '/pdf-reader';
  static const String backup = '/backup';
  static const String settings = '/settings';

  // 路由参数名
  static const String bookIdParam = 'bookId';
}

/// 全局路由导航键
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// 构建应用路由配置
GoRouter createRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.bookshelf,
    debugLogDiagnostics: true,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bookshelf,
                name: 'bookshelf',
                builder: (context, state) => const BookshelfPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.discover,
                name: 'discover',
                builder: (context, state) => const DiscoverPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.source,
                name: 'source',
                builder: (context, state) => const SourcePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.reader,
        name: 'reader',
        builder: (context, state) {
          final bookId = state.uri.queryParameters['bookId'] ?? '';
          return ReaderPage(bookId: bookId);
        },
      ),
      GoRoute(
        path: AppRoutes.pdfReader,
        name: 'pdf-reader',
        builder: (context, state) {
          final bookId = state.uri.queryParameters['bookId'] ?? '';
          final filePath = state.uri.queryParameters['filePath'] ?? '';
          return PdfReaderPage(bookId: bookId, filePath: filePath);
        },
      ),
      GoRoute(
        path: AppRoutes.backup,
        name: 'backup',
        builder: (context, state) => const BackupPage(),
      ),
    ],
  );
}

/// 底部导航栏壳 - iOS 风格半透明毛玻璃
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xCC000000)
                  : const Color(0xCCFFFFFF),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? const Color(0xFF38383A)
                      : const Color(0xFFE5E5EA),
                  width: 0.5,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book),
                  label: '书架',
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore),
                  label: '发现',
                ),
                NavigationDestination(
                  icon: Icon(Icons.layers_outlined),
                  selectedIcon: Icon(Icons.layers),
                  label: '书源',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: '我的',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
