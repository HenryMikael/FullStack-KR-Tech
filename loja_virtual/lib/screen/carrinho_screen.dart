// lib/screen/carrinho_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'carrinho_provider.dart';

class CarrinhoScreen extends StatefulWidget {
  const CarrinhoScreen({super.key});

  static const Color brandBlue = Color(0xFF435394);
  static const Color appTeal = Color(0xFF53B1B1);

  @override
  State<CarrinhoScreen> createState() => _CarrinhoScreenState();
}

class _CarrinhoScreenState extends State<CarrinhoScreen> {
  @override
  void initState() {
    super.initState();
    // Busca automática assim que a tela abre
    Provider.of<CarrinhoProvider>(context, listen: false).buscarItensDoBanco();
  }

  @override
  Widget build(BuildContext context) {
    final carrinho = Provider.of<CarrinhoProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: CarrinhoScreen.brandBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Meu Carrinho',
          style: TextStyle(color: CarrinhoScreen.brandBlue, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: CarrinhoScreen.appTeal, size: 26),
            onPressed: () => carrinho.buscarItensDoBanco(),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: carrinho.carregando
          ? const Center(child: CircularProgressIndicator(color: CarrinhoScreen.appTeal))
          : carrinho.itens.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.redAccent),
                      const SizedBox(height: 15),
                      // MENSAGEM EM VERMELHO SE ESTIVER VAZIO OU SE DER ERRO NO BACK
                      Text(
                        carrinho.mensagemErro.isNotEmpty 
                            ? carrinho.mensagemErro 
                            : 'Seu carrinho está vazio!', 
                        style: const TextStyle(
                          color: Colors.redAccent, // CORRIGIDO: Mensagem Vermelha
                          fontSize: 16, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: carrinho.itens.length,
                        itemBuilder: (context, index) {
                          final item = carrinho.itens[index]; 
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[100],
                                child: const Icon(Icons.shopping_bag_outlined, color: CarrinhoScreen.appTeal),
                              ),
                              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, color: CarrinhoScreen.brandBlue)),
                              subtitle: Text(
                                'Qtd: ${item.quantity}x | R\$ ${item.price.toStringAsFixed(2)}\nSubtotal: R\$ ${item.subtotal.toStringAsFixed(2)}', 
                                style: const TextStyle(color: Colors.black54),
                              ),
                              isThreeLine: true,
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () => carrinho.removerProduto(item.id), 
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CarrinhoScreen.brandBlue)),
                              Text('R\$ ${carrinho.valorTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CarrinhoScreen.appTeal)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Pedido processado com sucesso!'), backgroundColor: CarrinhoScreen.appTeal),
                                );
                                Navigator.pushReplacementNamed(context, '/dashboard');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CarrinhoScreen.brandBlue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              ),
                              child: const Text('Fechar Pedido', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
    );
  }
}