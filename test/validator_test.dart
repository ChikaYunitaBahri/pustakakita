import 'package:flutter_test/flutter_test.dart';
import 'package:pustakakita/utils/validator.dart';

void main() {
  group('Validator.email', () {
    test('kosong atau null ditolak', () {
      expect(Validator.email(null), 'Email wajib diisi');
      expect(Validator.email(''), 'Email wajib diisi');
      expect(Validator.email('   '), 'Email wajib diisi');
    });

    test('format tidak valid ditolak', () {
      expect(Validator.email('nadylla'), 'Format email tidak valid');
      expect(Validator.email('nadylla@contoh'), 'Format email tidak valid');
      expect(Validator.email('nadylla@contoh.'), 'Format email tidak valid');
      expect(Validator.email('@contoh.com'), 'Format email tidak valid');
    });

    test('format valid diterima, spasi di tepi diabaikan', () {
      expect(Validator.email('nadylla@contoh.com'), isNull);
      expect(Validator.email('  nadylla@contoh.com  '), isNull);
    });
  });

  group('Validator.password', () {
    test('kosong atau null ditolak', () {
      expect(Validator.password(null), 'Password wajib diisi');
      expect(Validator.password(''), 'Password wajib diisi');
    });

    test('terisi diterima', () {
      expect(Validator.password('rahasia123'), isNull);
    });
  });
}
