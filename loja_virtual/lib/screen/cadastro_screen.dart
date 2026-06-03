// lib/screen/cadastro_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _isLoading = false;

  // Flags para controlar se a caixa deve ficar vermelha por erro
  bool _nomeComErro = false;
  bool _emailComErro = false;
  bool _senhaComErro = false;
  bool _confirmarComErro = false;

  // Textos padrão que aparecem dentro das caixas
  String _hintNome = 'Nome Completo';
  String _hintEmail = 'E-mail';
  String _hintSenha = 'Password';
  String _hintConfirmar = 'Confirmar Password';

  // Função centralizada para exibir notificações flutuando no TOPO da tela de forma fixa
  void _mostrarNotificacaoNoTopo(String mensagem, {bool isErro = false}) {
    ScaffoldMessenger.of(context).clearSnackBars(); // Limpa avisos antigos imediatamente
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isErro ? const Color(0xFFD95353) : const Color(0xFF53B1B1),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.up,
        margin: EdgeInsets.only(
          top: 20, // Distância fixa do topo da janela
          bottom: MediaQuery.of(context).size.height - 80, // Força a barra a subir na Web
          left: 40,
          right: 40,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _registrarConta() async {
    // Reseta o visual padrão das caixas e os textos de dica
    setState(() {
      _nomeComErro = false;
      _emailComErro = false;
      _senhaComErro = false;
      _confirmarComErro = false;
      
      _hintNome = 'Nome Completo';
      _hintEmail = 'E-mail';
      _hintSenha = 'Password';
      _hintConfirmar = 'Confirmar Password';
    });

    bool temErro = false;

    // Validação local: deixa a caixa vermelha e injeta o aviso dentro dela
    if (_nomeController.text.trim().isEmpty) {
      setState(() {
        _nomeComErro = true;
        _hintNome = 'O nome completo é obrigatório!';
      });
      temErro = true;
    }
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _emailComErro = true;
        _hintEmail = 'O e-mail é obrigatório!';
      });
      temErro = true;
    }
    if (_senhaController.text.isEmpty) {
      setState(() {
        _senhaComErro = true;
        _hintSenha = 'A senha é obrigatória!';
      });
      temErro = true;
    }
    if (_confirmarController.text.isEmpty) {
      setState(() {
        _confirmarComErro = true;
        _hintConfirmar = 'Confirme sua senha!';
      });
      temErro = true;
    }

    // Se os campos foram preenchidos mas as senhas não batem
    if (!temErro && _senhaController.text != _confirmarController.text) {
      _senhaController.clear();
      _confirmarController.clear();
      setState(() {
        _senhaComErro = true;
        _confirmarComErro = true;
        _hintSenha = 'As senhas não coincidem!';
        _hintConfirmar = 'As senhas não coincidem!';
      });
      temErro = true;
    }

    if (temErro) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/register'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': _nomeController.text.trim(),
          'email': _emailController.text.trim(),
          'senha': _senhaController.text,
          'confirmar_senha': _confirmarController.text,
        }),
      );

      final rDados = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _mostrarNotificacaoNoTopo(rDados['message'] ?? 'Código enviado!');
        Navigator.pushNamed(context, '/confirmar_codigo', arguments: {'email': _emailController.text.trim(), 'isRecovery': false});
      } else {
        String msgErro = rDados['message'] ?? rDados['error'] ?? 'Erro no registro';
        
        setState(() {
          if (msgErro.toLowerCase().contains('email') || msgErro.toLowerCase().contains('já cadastrado')) {
            _emailController.clear();
            _emailComErro = true;
            _hintEmail = msgErro;
          } else if (msgErro.toLowerCase().contains('nome')) {
            _nomeController.clear();
            _nomeComErro = true;
            _hintNome = msgErro;
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
      _mostrarNotificacaoNoTopo('Falha de conexão com a API', isErro: true);
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Image(image: NetworkImage('icons/logologinn.png'), height: 180),
                const SizedBox(height: 25),
                
                _buildField(
                  hintText: _hintNome, 
                  icon: Icons.person_outline, 
                  controller: _nomeController,
                  temErro: _nomeComErro,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 15),
                
                _buildField(
                  hintText: _hintEmail, 
                  icon: Icons.email_outlined, 
                  controller: _emailController,
                  temErro: _emailComErro,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 15),
                
                _buildField(
                  hintText: _hintSenha, 
                  icon: Icons.lock_outline, 
                  controller: _senhaController, 
                  isPass: true,
                  temErro: _senhaComErro,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 15),
                
                _buildField(
                  hintText: _hintConfirmar, 
                  icon: Icons.lock_outline, 
                  controller: _confirmarController, 
                  isPass: true,
                  temErro: _confirmarComErro,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _isLoading ? null : _registrarConta(),
                ),
                const SizedBox(height: 30),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: _isLoading ? null : _registrarConta,
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('Cadastrar', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String hintText, 
    required IconData icon, 
    required TextEditingController controller, 
    required bool temErro,
    bool isPass = false,
    TextInputAction? textInputAction,
    Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller, 
      obscureText: isPass, 
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText, 
        hintStyle: TextStyle(color: temErro ? Colors.red[100] : Colors.white70, fontWeight: temErro ? FontWeight.bold : FontWeight.normal),
        prefixIcon: Icon(icon, color: Colors.white), 
        filled: true, 
        fillColor: temErro ? const Color(0xFFD95353) : const Color(0xFF53B1B1),
        
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    );
  }
}