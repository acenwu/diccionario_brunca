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
    await _db.toggleFavorite(_word.id, newValue);
    if (!mounted) return;
    setState(() {
      _word.isFavorite = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSenses = _word.senses.isNotEmpty;
    final bool hasExamples = _word.examples.isNotEmpty;
    final bool hasPhrases = _word.phrases.isNotEmpty;
    final bool hasNote = _word.note != null && _word.note!.isNotEmpty;
    final bool hasCategory =
        _word.category != null && _word.category!.isNotEmpty;
    final bool hasAudio =
        _word.audioFile != null && _word.audioFile!.isNotEmpty;

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
            _buildHeader(),
            if (hasSenses) ...[
              _sectionTitle(_word.senses.length > 1 ? 'Significados' : 'Significado'),
              _buildSenses(),
            ],
            if (hasExamples) ...[
              _sectionTitle('Ejemplos'),
              for (final example in _word.examples) _buildExample(example),
            ],
            if (hasPhrases) ...[
              _sectionTitle('Locuciones y expresiones'),
              for (final phrase in _word.phrases) _buildPhrase(phrase),
            ],
            if (hasNote) ...[
              _sectionTitle('Nota'),
              Text(
                _word.note!,
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
            ],
            if (hasCategory) ...[
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(Icons.label_outline, size: 18),
                  label: Text(_word.category!),
                ),
              ),
            ],
            if (hasAudio) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(Icons.volume_up),
                label: const Text('Escuchar pronunciación'),
                onPressed: () {
                  // Audio playback isn't wired up yet — no audio player
                  // dependency exists in the project so far. This is a
                  // placeholder so the affordance is in place once one is
                  // added.
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

  /// Headword card: homograph number, headword, variants, part of speech.
  Widget _buildHeader() {
    final String variantsText = _word.variants.join(', ');

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  if (_word.homograph != null)
                    TextSpan(
                      text: '${_word.homograph} ',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  TextSpan(
                    text: _word.brunca,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            if (_word.variants.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'También: $variantsText',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
            if (_word.posLabel != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(label: Text(_word.posLabel!)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  /// A single gloss reads as plain text; several are numbered, like the
  /// printed dictionary's senses.
  Widget _buildSenses() {
    final senses = _word.senses;

    final List<Widget> children = [];
    if (senses.length == 1) {
      children.add(Text(senses.first, style: const TextStyle(fontSize: 18)));
    } else {
      for (var i = 0; i < senses.length; i++) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${i + 1}.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ),
                Expanded(
                  child: Text(
                    senses[i],
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    if (_word.literal != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Literalmente: ${_word.literal}',
            style: TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildExample(WordExample example) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.blue.shade200, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            example.brunca,
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 2),
          Text(
            example.spanish,
            style: TextStyle(fontSize: 15, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildPhrase(WordPhrase phrase) {
    final String translation = phrase.literal == null
        ? phrase.spanish
        : '${phrase.spanish} (literalmente: ${phrase.literal})';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            phrase.brunca,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            translation,
            style: TextStyle(fontSize: 15, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
