// lib/screen/reescreversenha_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReescreverSenhaScreen extends StatefulWidget {
  const ReescreverSenhaScreen({super.key});

  @override
  State<ReescreverSenhaScreen> createState() => _ReescreverSenhaScreenState();
}

class _ReescreverSenhaScreenState extends State<ReescreverSenhaScreen> {
  final _senhaController = TextEditingController();
  bool _isLoading = false;

  Future<void> _atualizarSenha(String email) async {
    if (_senhaController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'nova_senha': _senhaController.text
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha redefinida com sucesso!')));
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível alterar a senha.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falha de conexão')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String email = args['email'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Image(image: NetworkImage('icons/logologinn.png'), height: 220),
              const SizedBox(height: 45),
              TextField(
                controller: _senhaController, obscureText: true, style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(hintText: 'Nova Senha', prefixIcon: const Icon(Icons.lock, color: Colors.white), filled: true, fillColor: const Color(0xFF53B1B1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: _isLoading ? null : () => _atualizarSenha(email),
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Alterar Senha', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}