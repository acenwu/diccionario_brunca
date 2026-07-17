class Word {
  final int? id;
  final String spanish;
  final String brunca;
  final String? category;
  final String? audioFile;
  bool isFavorite;

  Word({
    this.id,
    required this.spanish,
    required this.brunca,
    this.category,
    this.audioFile,
    this.isFavorite = false,
  });

  // Convertir desde base de datos a objeto
  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      spanish: map['spanish'],
      brunca: map['brunca'],
      category: map['category'],
      audioFile: map['audioFile'],
      isFavorite: map['isFavorite'] == 1,
    );
  }

  // Convertir de objeto a fila de base de datos
  Map<String, dynamic> toMap() {
    return {
      'spanish': spanish,
      'brunca': brunca,
      'category': category,
      'audioFile': audioFile,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }
}
