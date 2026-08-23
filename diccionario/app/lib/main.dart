import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/word.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diccionario Brunca',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _results = [];
                            _isSearching = false;
                          });
                        },
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
                                    onTap: () {
                                      // We'll add details view later
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '${word.spanish} → ${word.brunca}'),
                                        ),
                                      );
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
