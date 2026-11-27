import 'package:flutter/material.dart';

import '../services/auth_php_api.dart';

class RegisterPhpScreen extends StatefulWidget {
  const RegisterPhpScreen({super.key});

  @override
  State<RegisterPhpScreen> createState() => _RegisterPhpScreenState();
}

class _RegisterPhpScreenState extends State<RegisterPhpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _konfirmasiCtrl = TextEditingController();
  bool _sembunyikan = true;
  bool _loading = false;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _konfirmasiCtrl.dispose();
    super.dispose();
  }

  // Aturan sama dengan backend (register.php): nama 3-100, password 8-72.
  String? _validasiNama(String? v) {
    final teks = v?.trim() ?? '';
    if (teks.isEmpty) return 'Nama wajib diisi';
    if (teks.length < 3) return 'Nama minimal 3 karakter';
    if (teks.length > 100) return 'Nama maksimal 100 karakter';
    return null;
  }

  String? _validasiEmail(String? v) {
    final teks = v?.trim() ?? '';
    if (teks.isEmpty) return 'Email wajib diisi';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(teks)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validasiPassword(String? v) {
    if (v == null || v.isEmpty) return 'Password wajib diisi';
    if (v.length < 8) return 'Password minimal 8 karakter';
    if (v.length > 72) return 'Password maksimal 72 karakter';
    return null;
  }

  String? _validasiKonfirmasi(String? v) {
    if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
    if (v != _passCtrl.text) return 'Konfirmasi password tidak sama';
    return null;
  }

  Future<void> _daftar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AuthPhpApi.register(
        _namaCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil, silakan login')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } on AuthPhpException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.pesan)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _namaCtrl,
                        textInputAction: TextInputAction.next,
                        validator: _validasiNama,
                        decoration: const InputDecoration(
                          labelText: 'Nama',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _validasiEmail,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _sembunyikan,
                        textInputAction: TextInputAction.next,
                        validator: _validasiPassword,
                        decoration: InputDecoration(
                          labelText: 'Password (minimal 8 karakter)',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_sembunyikan
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () =>
                                setState(() => _sembunyikan = !_sembunyikan),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _konfirmasiCtrl,
                        obscureText: _sembunyikan,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _daftar(),
                        validator: _validasiKonfirmasi,
                        decoration: const InputDecoration(
                          labelText: 'Konfirmasi password',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _loading ? null : _daftar,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Daftar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
