import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../services/firestore_service.dart';
import '../services/pdf_service.dart'; // Importe o PdfService
import '../models/estoque_model.dart';
import '../models/tratamento_model.dart';
import 'pdf_viewer_screen.dart'; // Tela para visualizar o PDF

class EstoqueScreen extends StatelessWidget {
  final PdfService pdfService = PdfService(); // Instância do PdfService

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Estoque')),
      body: StreamBuilder<List<Estoque>>(
        stream: firestoreService.getEstoques(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildShimmerEffect(); // Exibe o shimmer enquanto os dados carregam
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar estoques: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum estoque encontrado'));
          } else {
            final estoques = snapshot.data!;
            return ListView.builder(
              itemCount: estoques.length,
              itemBuilder: (context, index) {
                final estoque = estoques[index];
                return FutureBuilder<Tratamento?>(
                  future: firestoreService.getTratamentoPorLote(estoque.lote),
                  builder: (context, tratamentoSnapshot) {
                    final tratamento = tratamentoSnapshot.data;
                    final status = tratamento?.status ?? 'Soja Branca';

                    final corEtiqueta = tratamento?.corEtiqueta ?? 'N/A';
                    final produtos = tratamento?.produtos ?? [];
                    final detalhesTratamento =
                        tratamento != null
                            ? 'Detalhes do Tratamento: ${tratamento.produtos.map((produto) => '${produto['nome']} (${produto['dosagem']})').join(', ')}'
                            : 'Nenhum tratamento aplicado';

                    return Card(
                      margin: EdgeInsets.all(8),
                      color: Colors.blueGrey[800],
                      child: ExpansionTile(
                        title: Text('Lote: ${estoque.lote}'),
                        subtitle: Text(
                          'Câmara Fria: ${estoque.camaraFria} - Status: $status',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.picture_as_pdf,
                                color: Colors.white,
                              ),
                              // Botão para visualizar PDF
                              onPressed: () async {
                                final pdf = await pdfService.generateEstoquePdf(
                                  estoque,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => PdfViewerScreen(pdf: pdf),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.white),
                              // Botão para editar
                              onPressed: () {
                                _showEditEstoqueDialog(
                                  context,
                                  firestoreService,
                                  estoque,
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              // Botão para deletar
                              onPressed: () async {
                                await firestoreService.deleteEstoque(
                                  estoque.id,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Estoque deletado com sucesso!',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cor da Etiqueta: $corEtiqueta',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Status: $status',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Produtos Usados:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ...produtos.map((produto) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      '- ${produto['nome']} (Dosagem: ${produto['dosagem']})',
                                    ),
                                  );
                                }).toList(),
                                //////////////////////////////////////////
                                Text('Status: $status'),
                                Text(detalhesTratamento),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEstoqueDialog(context, firestoreService);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5, // Número de itens no skeleton
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            color: Colors.white,
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.grey[200]),
              title: Container(
                width: double.infinity,
                height: 16.0,
                color: Colors.grey[200],
              ),
              subtitle: Container(
                width: double.infinity,
                height: 12.0,
                color: Colors.grey[200],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddEstoqueDialog(
    BuildContext context,
    FirestoreService firestoreService,
  ) {
    final TextEditingController _loteController = TextEditingController();
    final TextEditingController _camaraFriaController = TextEditingController();
    final TextEditingController _produtorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Estoque'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _loteController,
                  decoration: InputDecoration(labelText: 'Lote'),
                ),
                TextField(
                  controller: _camaraFriaController,
                  decoration: InputDecoration(labelText: 'Câmara Fria'),
                ),
                TextField(
                  controller: _produtorController,
                  decoration: InputDecoration(labelText: 'Produtor'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final estoque = Estoque(
                  id: '', // O Firestore gera o ID automaticamente
                  lote: _loteController.text,
                  camaraFria: _camaraFriaController.text,
                  produtor: _produtorController.text,
                  tratado: false, // Valor padrão
                );

                await firestoreService.addEstoque(estoque);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Estoque adicionado com sucesso!')),
                );

                Navigator.pop(context);
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditEstoqueDialog(
    BuildContext context,
    FirestoreService firestoreService,
    Estoque estoque,
  ) {
    final TextEditingController _loteController = TextEditingController(
      text: estoque.lote,
    );
    final TextEditingController _camaraFriaController = TextEditingController(
      text: estoque.camaraFria,
    );
    final TextEditingController _produtorController = TextEditingController(
      text: estoque.produtor,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Estoque'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _loteController,
                  decoration: InputDecoration(labelText: 'Lote'),
                ),
                TextField(
                  controller: _camaraFriaController,
                  decoration: InputDecoration(labelText: 'Câmara Fria'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final estoqueEditado = Estoque(
                  id: estoque.id,
                  lote: _loteController.text,
                  camaraFria: _camaraFriaController.text,
                  produtor: _produtorController.text,
                  tratado: estoque.tratado, // Mantém o valor atual
                );

                await firestoreService.updateEstoque(estoqueEditado);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Estoque atualizado com sucesso!')),
                );

                Navigator.pop(context);
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}
