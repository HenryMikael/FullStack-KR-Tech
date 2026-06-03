// lib/screen/confirmarcodigo_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConfirmarCodigoScreen extends StatefulWidget {
  const ConfirmarCodigoScreen({super.key});

  @override
  State<ConfirmarCodigoScreen> createState() => _ConfirmarCodigoScreenState();
}

class _ConfirmarCodigoScreenState extends State<ConfirmarCodigoScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _validarToken(String email, bool isRecovery) async {
    setState(() => _isLoading = true);
    
    // Define a rota do seu back dinamicamente baseado no fluxo
    final url = isRecovery 
        ? 'http://127.0.0.1:5000/verify-recover-code' 
        : 'http://127.0.0.1:5000/verify-email';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'codigo': _codeController.text.trim()
        }),
      );

      final rDados = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (isRecovery) {
          Navigator.pushNamed(context, '/reescrever_senha', arguments: {'email': email});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conta ativada com sucesso!')));
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(rDados['error'] ?? 'Código inválido')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro interno')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String email = args['email'];
    final bool isRecovery = args['isRecovery'];

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
                controller: _codeController, keyboardType: TextInputType.number, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 8),
                decoration: InputDecoration(hintText: '000000', filled: true, fillColor: const Color(0xFF53B1B1), contentPadding: const EdgeInsets.only(top: 19, bottom: 19, right: 9 ), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: _isLoading ? null : () => _validarToken(email, isRecovery),
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Verificar Código', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}