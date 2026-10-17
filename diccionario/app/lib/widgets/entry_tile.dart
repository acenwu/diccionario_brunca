import 'package:flutter/material.dart';
import '../models/word.dart';

/// One dictionary entry as a list row. Shared by the search results and the
/// favorites list so both always look (and behave) the same.
class EntryTile extends StatelessWidget {
  final Word word;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const EntryTile({
    super.key,
    required this.word,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      if (word.posLabel != null) word.posLabel!,
      if (word.gloss.isNotEmpty) word.gloss,
    ];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text.rich(
          TextSpan(
            children: [
              // Homograph number, printed before the headword as in the book
              // ("1 abí", "2 abí").
              if (word.homograph != null)
                TextSpan(
                  text: '${word.homograph} ',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              TextSpan(
                text: word.headline,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        subtitle: Text(
          subtitleParts.join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: Icon(
            word.isFavorite ? Icons.star : Icons.star_border,
            color: word.isFavorite ? Colors.amber : Colors.grey,
          ),
          tooltip:
              word.isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
          onPressed: onToggleFavorite,
        ),
        onTap: onTap,
      ),
    );
  }
}
