// lib/screen/dashboardscreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'carrinho_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color appTeal = Color(0xFF53B1B1);
  
  // URL para o Emulador do Android Studio se conectar ao Flask local
  final String baseUrl = 'http://127.0.0.1:5000';

  // Estados de controle da tela unificada
  String _categoriaSelecionada = 'Todos';
  String _filtroPesquisa = '';
  final TextEditingController _searchController = TextEditingController();

  // 1. BUSCA AS CATEGORIAS DIRETO DO BANCO DE DADOS
  Future<List<String>> _buscarCategorias() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));
      if (response.statusCode == 200) {
        List<dynamic> dados = jsonDecode(response.body);
        List<String> listaCategorias = ['Todos']; // Filtro padrão para limpar busca
        
        for (var cat in dados) {
          if (cat['nome'] != null) {
            listaCategorias.add(cat['nome']);
          }
        }
        return listaCategorias;
      }
    } catch (e) {
      debugPrint('Erro ao buscar categorias do banco: $e');
    }
    return ['Todos']; // Retorno de segurança se o back estiver desligado
  }

  // 2. BUSCA OS PRODUTOS USANDO OS FILTROS DA MESMA TELA
  Future<List<Map<String, dynamic>>> _buscarProdutos() async {
    try {
      String urlCompleta = '$baseUrl/products';
      List<String> parametros = [];

      // Se não for 'Todos', põe o filtro de categoria na URL (?categoria=Nome)
      if (_categoriaSelecionada != 'Todos') {
        parametros.add('categoria=$_categoriaSelecionada');
      }
      // Se tiver algo digitado na pesquisa, põe o filtro de nome (?nome=Texto)
      if (_filtroPesquisa.isNotEmpty) {
        parametros.add('nome=$_filtroPesquisa');
      }

      if (parametros.isNotEmpty) {
        urlCompleta += '?${parametros.join('&')}';
      }

      final response = await http.get(Uri.parse(urlCompleta));

      if (response.statusCode == 200) {
        List<dynamic> dadosProdutos = jsonDecode(response.body);
        return dadosProdutos.map((item) {
          return {
            'id': item['id'].toString(),
            'name': item['nome'] ?? 'Sem nome',
            'price': double.tryParse(item['preco'].toString()) ?? 0.0,
            'categoria': item['categoria'] ?? 'Geral',
            'imagem_url': item['imagem_url'] ?? '',
            'descricao': item['descricao'] ?? '',
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('Erro ao buscar produtos do banco: $e');
    }
    return [];
  }

  // Define um ícone se o produto vir sem link de imagem do painel
  IconData _definirIconeReserva(String categoria) {
    String cat = categoria.toLowerCase();
    if (cat.contains('game') || cat.contains('jogo')) return Icons.sports_esports;
    if (cat.contains('smart') || cat.contains('celular') || cat.contains('phone')) return Icons.phone_iphone;
    if (cat.contains('periferico') || cat.contains('teclado') || cat.contains('mouse')) return Icons.keyboard;
    return Icons.devices;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: appTeal, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image.network(
          'icons/logologinn.png',
          height: 40,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Text('KR TEC', style: TextStyle(color: appTeal, fontWeight: FontWeight.bold));
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: appTeal, size: 26),
            onPressed: () => Navigator.pushNamed(context, '/carrinho'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: appTeal, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: appTeal), 
              child: Text('Menu KR TEC', style: TextStyle(color: Colors.white, fontSize: 24))
            ),
            ListTile(
              leading: const Icon(Icons.home, color: appTeal), 
              title: const Text('Início / Atualizar'), 
              onTap: () {
                setState(() {
                  _categoriaSelecionada = 'Todos';
                  _filtroPesquisa = '';
                  _searchController.clear();
                });
                Navigator.pop(context);
              }
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red), 
              title: const Text('Sair'), 
              onTap: () => Navigator.pushReplacementNamed(context, '/login')
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. BARRA DE PESQUISA DINÂMICA
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: _searchController,
                onChanged: (valor) {
                  setState(() {
                    _filtroPesquisa = valor.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Pesquisar produtos...',
                  prefixIcon: const Icon(Icons.search, color: appTeal),
                  suffixIcon: _filtroPesquisa.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _filtroPesquisa = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // 2. BOTÕES DE CATEGORIA GERADOS DIRETO DO BANCO DE DADOS
            SizedBox(
              height: 40,
              child: FutureBuilder<List<String>>(
                future: _buscarCategorias(),
                builder: (context, snapshot) {
                  final categorias = snapshot.data ?? ['Todos'];
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: categorias.length,
                    itemBuilder: (context, index) {
                      final cat = categorias[index];
                      final bool isSelecionada = cat == _categoriaSelecionada;

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              color: isSelecionada ? Colors.white : appTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelecionada,
                          selectedColor: appTeal,
                          backgroundColor: Colors.grey[100],
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: isSelecionada ? appTeal : Colors.transparent),
                          ),
                          onSelected: (bool selecionado) {
                            setState(() {
                              _categoriaSelecionada = cat; // Altera o estado e filtra a lista abaixo
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // 3. GRADE DE PRODUTOS DINÂMICA
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _buscarProdutos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: appTeal));
                  }

                  final produtos = snapshot.data ?? [];

                  if (produtos.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum produto encontrado.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(15),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      crossAxisSpacing: 12, 
                      mainAxisSpacing: 12, 
                      childAspectRatio: 0.78
                    ),
                    itemCount: produtos.length,
                    itemBuilder: (context, index) {
                      final prod = produtos[index];
                      final String imgUrl = prod['imagem_url'];

                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity, 
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: imgUrl.isNotEmpty
                                    ? Image.network(
                                        imgUrl,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(_definirIconeReserva(prod['categoria']), size: 40, color: appTeal);
                                        },
                                      )
                                    : Icon(_definirIconeReserva(prod['categoria']), size: 40, color: appTeal),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              prod['name'], 
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: appTeal, fontSize: 14),
                            ),
                            Text(
                              'R\$ ${prod['price'].toStringAsFixed(2)}', 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: double.infinity, 
                              height: 30,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: appTeal, 
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                                ),
                                onPressed: () {
                                  Provider.of<CarrinhoProvider>(context, listen: false)
                                      .adicionarProduto(prod['id'], prod['name'], prod['price'], imgUrl.isNotEmpty ? imgUrl : 'icons/store.png');
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${prod['name']} adicionado ao carrinho!'),
                                      duration: const Duration(milliseconds: 500),
                                      backgroundColor: appTeal,
                                    ),
                                  );
                                },
                                child: const Text('Adicionar', style: TextStyle(color: Colors.white, fontSize: 11)),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}