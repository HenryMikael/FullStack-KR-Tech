// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screen/login_screen.dart';
import 'screen/dashboard_screen.dart';
import 'screen/cadastro_screen.dart';
import 'screen/carrinho_screen.dart';
import 'screen/carrinho_provider.dart';
import 'screen/reset-password.dart';
import 'screen/confirmarcodigo_screen.dart';
import 'screen/reescreversenha_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CarrinhoProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KR Tec App',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/cadastro': (context) => const CadastroScreen(),
        '/carrinho': (context) => const CarrinhoScreen(),
        '/esqueceu_senha': (context) => const EsqueceuSenhaScreen(),
        '/confirmar_codigo': (context) => const ConfirmarCodigoScreen(),
        '/reescrever_senha': (context) => const ReescreverSenhaScreen(),
      },
    );
  }
}