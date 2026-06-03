// lib/screen/carrinho_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartItemModel {
  final String id;        // item_id do banco
  final String name;      // nome que vem na chave 'produto'
  final double price;     // preco
  int quantity;           // quantidade
  final double subtotal;  // subtotal

  CartItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });
}

class CarrinhoProvider with ChangeNotifier {
  final String baseUrl = 'http://127.0.0.1:5000';
  final int userId = 1; // ID padrão de teste para bater com o banco
  
  List<CartItemModel> _itens = [];
  double _totalGeral = 0.0;
  bool _carregando = false;
  String _mensagemErro = ''; 

  List<CartItemModel> get itens => [..._itens];
  double get valorTotal => _totalGeral;
  bool get carregando => _carregando;
  String get mensagemErro => _mensagemErro;

  // =========================================================================
  // 1. LISTAR CART (GET /cart/<user_id>)
  // =========================================================================
  Future<void> buscarItensDoBanco() async {
    _carregando = true;
    _mensagemErro = ''; 
    Future.delayed(Duration.zero, () => notifyListeners());

    try {
      final response = await http.get(Uri.parse('$baseUrl/cart/$userId'));
      
      if (response.statusCode == 200) {
        final dados = jsonDecode(response.body);

        if (dados is Map && dados.containsKey('error')) {
          _itens = [];
          _totalGeral = 0.0;
          _mensagemErro = dados['error'].toString(); 
        } else if (dados is Map) {
          _totalGeral = double.tryParse(dados['total'].toString()) ?? 0.0;
          List<dynamic> listaItens = dados['itens'] ?? [];
          
          _itens = listaItens.map((item) {
            return CartItemModel(
              id: item['item_id'] != null ? item['item_id'].toString() : '',
              name: item['produto'] ?? 'Produto', 
              price: double.tryParse(item['preco'].toString()) ?? 0.0,
              quantity: item['quantidade'] ?? 1,
              subtotal: double.tryParse(item['subtotal'].toString()) ?? 0.0,
            );
          }).toList();
        }
      } else {
        _mensagemErro = 'Erro ao carregar dados do servidor (${response.statusCode})';
      }
    } catch (e) {
      _mensagemErro = 'Sem conexão com o servidor Flask.';
      debugPrint('Erro: $e');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  // =========================================================================
  // 2. ADICIONAR PRODUTO AO CARRINHO (POST /cart/add)
  // =========================================================================
  Future<void> adicionarProduto(String productId, String nome, double preco, String imagemUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'product_id': int.parse(productId),
          'quantidade': 1
        }),
      );

      if (response.statusCode == 200) {
        await buscarItensDoBanco(); 
      }
    } catch (e) {
      debugPrint('Erro ao adicionar produto: $e');
    }
  }

  // =========================================================================
  // 3. ALTERAR QUANTIDADE (PUT /cart/item/<item_id>)
  // =========================================================================
  Future<void> alterarQuantidade(String itemId, int novaQuantidade) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/cart/item/$itemId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'quantidade': novaQuantidade
        }),
      );

      if (response.statusCode == 200) {
        await buscarItensDoBanco(); 
      }
    } catch (e) {
      debugPrint('Erro ao alterar quantidade: $e');
    }
  }

  // =========================================================================
  // 4. REMOVER ITEM (DELETE /cart/item/<item_id>)
  // =========================================================================
  Future<void> removerProduto(String itemId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/cart/item/$itemId'));

      if (response.statusCode == 200) {
        await buscarItensDoBanco(); 
      }
    } catch (e) {
      debugPrint('Erro ao remover produto: $e');
    }
  }
}