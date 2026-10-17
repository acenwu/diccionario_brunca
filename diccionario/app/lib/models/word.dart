import 'dart:convert';

/// An example sentence: Boruca text plus its Spanish translation.
class WordExample {
  final String brunca;
  final String spanish;

  const WordExample({required this.brunca, required this.spanish});

  factory WordExample.fromMap(Map<String, dynamic> map) {
    return WordExample(
      brunca: map['brunca'] as String,
      spanish: map['spanish'] as String,
    );
  }
}

/// A phrase or compound listed under an entry (e.g. "yáᵛ áiᵛ" under "áiᵛ").
class WordPhrase {
  final String brunca;
  final String spanish;

  /// Word-for-word rendering, when the dictionary gives one
  /// ("literalmente: matarse").
  final String? literal;

  const WordPhrase({
    required this.brunca,
    required this.spanish,
    this.literal,
  });

  factory WordPhrase.fromMap(Map<String, dynamic> map) {
    return WordPhrase(
      brunca: map['brunca'] as String,
      spanish: map['spanish'] as String,
      literal: map['literal'] as String?,
    );
  }
}

/// One dictionary entry.
///
/// The class keeps the name `Word` for continuity, but an entry is no longer
/// a single spanish/brunca pair: it has a headword, optional spelling
/// variants, numbered senses (Spanish glosses), examples and phrases.
class Word {
  /// Stable, hand-assigned id from the source data (e.g. "abi-h1").
  /// Favorites are keyed on this, so it must never change once published.
  final String id;

  /// Headword, exactly as transcribed (tone marks, ᵛ and n̈ included).
  final String brunca;

  /// Alternate forms listed with the headword ("abí, abíj").
  final List<String> variants;

  /// Homograph number ("1 abí" / "2 abí"), when the dictionary numbers them.
  final int? homograph;

  /// Part-of-speech abbreviation as printed ("sust.") and its full label
  /// ("sustantivo"). Both come from the build script.
  final String? pos;
  final String? posLabel;

  /// Spanish glosses, one per sense.
  final List<String> senses;

  /// Entry-level literal translation ("literalmente: ...").
  final String? literal;

  final List<WordExample> examples;
  final List<WordPhrase> phrases;
  final String? note;
  final String? category;
  final String? audioFile;
  bool isFavorite;

  Word({
    required this.id,
    required this.brunca,
    this.variants = const [],
    this.homograph,
    this.pos,
    this.posLabel,
    this.senses = const [],
    this.literal,
    this.examples = const [],
    this.phrases = const [],
    this.note,
    this.category,
    this.audioFile,
    this.isFavorite = false,
  });

  /// Spanish glosses on one line: "luego, más tarde, en la tarde".
  String get gloss => senses.join(', ');

  /// Headword plus variants on one line: "abí, abíj".
  String get headline => [brunca, ...variants].join(', ');

  /// Builds a Word from a database row (JSON columns are stored as text) or
  /// from a decoded seed-JSON map (JSON columns are already lists).
  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'] as String,
      brunca: map['brunca'] as String,
      variants: List<String>.from(_decodeList(map['variants'])),
      homograph: map['homograph'] as int?,
      pos: map['pos'] as String?,
      posLabel: map['posLabel'] as String?,
      senses: List<String>.from(_decodeList(map['senses'])),
      literal: map['literal'] as String?,
      examples: _decodeList(map['examples'])
          .map((e) => WordExample.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      phrases: _decodeList(map['phrases'])
          .map((e) => WordPhrase.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      note: map['note'] as String?,
      category: map['category'] as String?,
      audioFile: map['audioFile'] as String?,
      isFavorite: map['isFavorite'] == 1,
    );
  }

  static List<dynamic> _decodeList(dynamic value) {
    if (value == null) return const [];
    if (value is String) return jsonDecode(value) as List<dynamic>;
    return value as List<dynamic>;
  }
}
