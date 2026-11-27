import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/auth_php_api.dart';
import '../utils/validator.dart';

class LoginPhpScreen extends StatefulWidget {
  const LoginPhpScreen({super.key});

  @override
  State<LoginPhpScreen> createState() => _LoginPhpScreenState();
}

class _LoginPhpScreenState extends State<LoginPhpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _sembunyikan = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final navigator = Navigator.of(context);
    setState(() => _loading = true);
    try {
      await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      navigator.pushNamedAndRemoveUntil('/', (route) => false);
    } on AuthPhpException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.pesan)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
                      Icon(Icons.menu_book,
                          size: 56, color: tema.colorScheme.primary),
                      const SizedBox(height: 8),
                      Text('PustakaKita',
                          textAlign: TextAlign.center,
                          style: tema.textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text('Masuk untuk meminjam buku',
                          textAlign: TextAlign.center,
                          style: tema.textTheme.bodyMedium),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validator.email,
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
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _masuk(),
                        validator: Validator.password,
                        decoration: InputDecoration(
                          labelText: 'Password',
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
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _loading ? null : _masuk,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Masuk'),
                      ),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () => Navigator.pushNamed(context, '/register'),
                        child: const Text('Belum punya akun? Daftar'),
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
