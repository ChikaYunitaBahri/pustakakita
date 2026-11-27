import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pustakakita/providers/auth_provider.dart';
import 'package:pustakakita/screens/login_php_screen.dart';

Widget _bungkus() {
  return ChangeNotifierProvider(
    create: (_) => AuthProvider(),
    child: const MaterialApp(home: LoginPhpScreen()),
  );
}

void main() {
  testWidgets('menekan Masuk dengan kolom kosong menampilkan pesan error',
      (tester) async {
    await tester.pumpWidget(_bungkus());

    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);
  });

  testWidgets('email dengan format salah menampilkan pesan format',
      (tester) async {
    await tester.pumpWidget(_bungkus());

    await tester.enterText(find.byType(TextFormField).at(0), 'bukan-email');
    await tester.enterText(find.byType(TextFormField).at(1), 'rahasia123');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();

    expect(find.text('Format email tidak valid'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsNothing);
  });
}
