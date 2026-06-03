// lib/screen/login_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _isLoading = false;

  // Flags para controlar se a caixa deve ficar vermelha
  bool _emailComErro = false;
  bool _senhaComErro = false;

  // Texto que aparece dentro das caixas de texto
  String _hintEmail = 'E-mail';
  String _hintSenha = 'senha';

  // Função atualizada para garantir o efeito flutuante no topo de forma fixa
  void _mostrarNotificacaoNoTopo(String mensagem, {bool isErro = false}) {
    ScaffoldMessenger.of(context).clearSnackBars(); // Limpa as antigas instantaneamente
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isErro ? const Color(0xFFD95353) : const Color(0xFF53B1B1),
        behavior: SnackBarBehavior.floating, // Faz o card flutuar
        dismissDirection: DismissDirection.up, // Permite arrastar para cima para sumir
        margin: EdgeInsets.only(
          top: 20, // Distância fixa do topo da janela/ecrã
          bottom: MediaQuery.of(context).size.height - 80, // Força a barra a subir na Web
          left: 40,
          right: 40,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _efetuarLogin() async {
    // Reseta o visual padrão das caixas
    setState(() {
      _emailComErro = false;
      _senhaComErro = false;
      _hintEmail = 'E-mail';
      _hintSenha = 'senha';
    });

    bool temErro = false;

    // Validação local: deixa a caixa vermelha e avisa dentro dela
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _emailComErro = true;
        _hintEmail = 'E-mail obrigatório!';
      });
      temErro = true;
    }
    if (_senhaController.text.isEmpty) {
      setState(() {
        _senhaComErro = true;
        _hintSenha = 'Senha obrigatória!';
      });
      temErro = true;
    }

    if (temErro) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/login'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'senha': _senhaController.text,
        }),
      );

      final rDados = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Alerta de sucesso flutuando lá em cima antes de ir para a dashboard
        _mostrarNotificacaoNoTopo('Login efetuado com sucesso!');
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        String msgErro = rDados['error'] ?? rDados['message'] ?? 'Erro ao entrar';
        
        // Trata os erros do back inserindo-os dentro das caixas sem quebrar o layout
        setState(() {
          if (msgErro.toLowerCase().contains('email') || msgErro.toLowerCase().contains('usuário')) {
            _emailController.clear();
            _emailComErro = true;
            _hintEmail = msgErro;
          } else if (msgErro.toLowerCase().contains('senha')) {
            _senhaController.clear();
            _senhaComErro = true;
            _hintSenha = msgErro;
          } else {
            _emailController.clear();
            _emailComErro = true;
            _hintEmail = msgErro;
          }
        });
      }
    } catch (e) {
      // Se der erro de conexão com o Flask, avisa lá no topo da tela de forma elegante
      _mostrarNotificacaoNoTopo('Sem conexão com o servidor Flask.', isErro: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Image(image: NetworkImage('icons/logologinn.png'), height: 220),
                const SizedBox(height: 40),
                
                _buildInputField(
                  hintText: _hintEmail,
                  icon: Icons.email,
                  controller: _emailController,
                  temErro: _emailComErro,
                  textInputAction: TextInputAction.next, 
                ),
                const SizedBox(height: 19),
                
                _buildInputField(
                  hintText: _hintSenha,
                  icon: Icons.lock,
                  isPassword: true,
                  controller: _senhaController,
                  temErro: _senhaComErro,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _isLoading ? null : _efetuarLogin(),
                ),
                
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/esqueceu_senha'),
                  child: const Text('esqueceu a senha?', style: TextStyle(color: Color(0xFF435394))),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: _isLoading ? null : _efetuarLogin,
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('Sign in', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Não tem conta?'),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/cadastro'),
                      child: const Text('Registre-se', style: TextStyle(color: Color(0xFF435394), fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    required TextEditingController controller,
    required bool temErro,
    TextInputAction? textInputAction,
    Function(String)? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: temErro ? Colors.red[100] : Colors.white70, fontWeight: temErro ? FontWeight.bold : FontWeight.normal),
          prefixIcon: Icon(icon, color: Colors.white),
          filled: true,
          // Fica vermelho em caso de erro, ou mantém o Teal original (0xFF53B1B1)
          fillColor: temErro ? const Color(0xFFD95353) : const Color(0xFF53B1B1),
          
          // Sem mensagens pulando para fora da caixa
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}