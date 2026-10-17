import 'package:flutter_test/flutter_test.dart';
import 'package:app/utils/text_fold.dart';

// Run just this file with:  flutter test test/text_fold_test.dart
//
// Special characters are written as \u escapes on purpose: they stay
// unambiguous even if an editor re-normalizes the file.
void main() {
  group('foldForSearch', () {
    test('lowercases, including accented capitals', () {
      expect(foldForSearch('\u00C1JT'), 'ajt');
    });

    test('drops tone marks', () {
      expect(foldForSearch('ab\u00ED'), 'abi');
      expect(foldForSearch('\u00E1jt'), foldForSearch('ajt'));
    });

    test('maps the glottal stop (U+1D5B) to a plain v', () {
      expect(foldForSearch('abu\u1D5B'), 'abuv');
      expect(foldForSearch('abuv'), foldForSearch('abu\u1D5B'));
    });

    test('drops the combining diaeresis of n-diaeresis (n + U+0308)', () {
      expect(foldForSearch('ajgo\u0301n\u0308'), 'ajgon');
    });

    test('folds \u00F1 and \u00FC', () {
      expect(foldForSearch('Espa\u00F1ol ping\u00FCino'), 'espanol pinguino');
    });

    test('handles decomposed (NFD) input the same as precomposed', () {
      expect(foldForSearch('a\u0301'), 'a');
      expect(foldForSearch('n\u0303'), 'n');
    });

    test('folds the typographic apostrophe', () {
      expect(foldForSearch('cr\u2019in'), "cr'in");
    });

    test('collapses and trims whitespace', () {
      expect(foldForSearch('  a   b '), 'a b');
    });

    test('empty input stays empty', () {
      expect(foldForSearch(''), '');
      expect(foldForSearch('   '), '');
    });
  });
}
