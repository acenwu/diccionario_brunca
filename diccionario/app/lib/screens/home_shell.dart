import 'package:flutter/material.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';

/// Hosts the bottom navigation and keeps both tabs alive via
/// [IndexedStack], so switching tabs doesn't lose your place.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  final GlobalKey<SearchScreenState> _searchKey =
      GlobalKey<SearchScreenState>();
  final GlobalKey<FavoritesScreenState> _favoritesKey =
      GlobalKey<FavoritesScreenState>();

  void _onTabTapped(int index) {
    // Tapping "Buscar" while already on it acts like a home button:
    // back to the blank starting state.
    if (index == 0 && _currentIndex == 0) {
      _searchKey.currentState?.reset();
      return;
    }

    setState(() => _currentIndex = index);

    // Favorites may be stale if a word was (un)favorited on another tab.
    if (index == 1) {
      _favoritesKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          SearchScreen(key: _searchKey),
          FavoritesScreen(key: _favoritesKey),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }
}
