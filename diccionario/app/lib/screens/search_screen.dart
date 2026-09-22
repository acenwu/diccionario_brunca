import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/word.dart';
import 'word_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

// Public (no leading underscore) so the bottom-nav shell can hold a
// GlobalKey<SearchScreenState> and call reset() on it directly.
class SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Word> _results = [];
  bool _isSearching = false;
  final DatabaseHelper _db = DatabaseHelper();

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await _db.searchWords(query);
    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  /// Clears the search field and results, back to the blank starting
  /// state. Called when "Buscar" is tapped while already on this tab.
  void reset() {
    _searchController.clear();
    setState(() {
      _results = [];
      _isSearching = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diccionario Brunca'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar en español...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: reset,
                      )
                    : null,
              ),
              onChanged: _search,
            ),
            const SizedBox(height: 16),

            // Results
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty && _searchController.text.isNotEmpty
                      ? const Center(
                          child: Text('No se encontraron palabras'),
                        )
                      : _results.isEmpty
                          ? const Center(
                              child: Text('Busca una palabra en español'),
                            )
                          : ListView.builder(
                              itemCount: _results.length,
                              itemBuilder: (context, index) {
                                final word = _results[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 4),
                                  child: ListTile(
                                    title: Text(word.spanish),
                                    subtitle: Text('Brunca: ${word.brunca}'),
                                    trailing: IconButton(
                                      icon: Icon(
                                        word.isFavorite
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: word.isFavorite
                                            ? Colors.amber
                                            : Colors.grey,
                                      ),
                                      onPressed: () async {
                                        await _db.toggleFavorite(
                                            word.id!, !word.isFavorite);
                                        setState(() {
                                          word.isFavorite = !word.isFavorite;
                                        });
                                      },
                                    ),
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              WordDetailScreen(word: word),
                                        ),
                                      );
                                      // isFavorite may have been toggled from
                                      // the detail screen (same Word instance),
                                      // so refresh the star icon in the list.
                                      setState(() {});
                                    },
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
