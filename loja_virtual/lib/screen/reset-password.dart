// lib/screen/esqueceuasenha_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EsqueceuSenhaScreen extends StatefulWidget {
  const EsqueceuSenhaScreen({super.key});

  @override
  State<EsqueceuSenhaScreen> createState() => _EsqueceuSenhaScreenState();
}

class _EsqueceuSenhaScreenState extends State<EsqueceuSenhaScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _requisitarRecuperacao() async {
    if (_emailController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:5000/recover-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text.trim()}),
      );

      if (response.statusCode == 200) {
        Navigator.pushNamed(context, '/confirmar_codigo', arguments: {'email': _emailController.text.trim(), 'isRecovery': true});
      } else {
        final err = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err['error'] ?? 'Erro')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falha na rede')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Image(image: NetworkImage('icons/logologinn.png'), height: 220),
              const SizedBox(height: 35),
              TextField(
                controller: _emailController, style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(hintText: 'E-mail', prefixIcon: const Icon(Icons.email, color: Colors.white), filled: true, fillColor: const Color(0xFF53B1B1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: _isLoading ? null : _requisitarRecuperacao,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Enviar Código', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}