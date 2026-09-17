import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/word.dart';

class WordDetailScreen extends StatefulWidget {
  final Word word;

  const WordDetailScreen({super.key, required this.word});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  late Word _word;

  @override
  void initState() {
    super.initState();
    _word = widget.word;
  }

  Future<void> _toggleFavorite() async {
    final newValue = !_word.isFavorite;
    await _db.toggleFavorite(_word.id!, newValue);
    setState(() {
      _word.isFavorite = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la palabra'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _word.isFavorite ? Icons.star : Icons.star_border,
              color: _word.isFavorite ? Colors.amber : Colors.white,
            ),
            tooltip:
                _word.isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Español',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _word.spanish,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(height: 1),
                    ),
                    Text(
                      'Brunca',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _word.brunca,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_word.category != null && _word.category!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(Icons.label_outline, size: 18),
                  label: Text(_word.category!),
                ),
              ),
            ],
            if (_word.audioFile != null && _word.audioFile!.isNotEmpty) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(Icons.volume_up),
                label: const Text('Escuchar pronunciación'),
                onPressed: () {
                  // Aún no se ha implementado la funcionaldad de audio,
                  // esto es placeholder por ahora
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('La reproducción de audio llegará pronto'),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
