import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/word.dart';
import '../widgets/entry_tile.dart';
import 'word_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => FavoritesScreenState();
}

// Public (no leading underscore) so the bottom-nav shell can hold a
// GlobalKey<FavoritesScreenState> and call refresh() when this tab
// is opened, in case a favorite changed elsewhere.
class FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  List<Word> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    setState(() => _isLoading = true);
    final favorites = await _db.getFavorites();
    if (!mounted) return;
    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(Word word) async {
    await _db.toggleFavorite(word.id, false);
    if (!mounted) return;
    setState(() {
      word.isFavorite = false;
      _favorites.removeWhere((w) => w.id == word.id);
    });
  }

  Future<void> _openDetail(Word word) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordDetailScreen(word: word),
      ),
    );
    // The word may have been unfavorited from the detail screen, so
    // re-query to stay accurate.
    if (mounted) refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'Aún no tienes palabras favoritas.\n'
                      'Toca la estrella junto a una palabra para guardarla aquí.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final word = _favorites[index];
                      return EntryTile(
                        word: word,
                        onTap: () => _openDetail(word),
                        onToggleFavorite: () => _removeFavorite(word),
                      );
                    },
                  ),
                ),
    );
  }
}
