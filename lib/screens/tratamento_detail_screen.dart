import 'package:flutter/material.dart';
import 'package:sementes_gurupi/models/estoque_model.dart';
import '../models/tratamento_model.dart';

class TratamentoDetailScreen extends StatelessWidget {
  final Tratamento tratamento;
  final Estoque estoque;

  TratamentoDetailScreen({required this.tratamento, required this.estoque});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Tratamento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lote: ${tratamento.lote}', style: TextStyle(fontSize: 18)),
            Text('Máquina: ${tratamento.maquina}', style: TextStyle(fontSize: 18)),
            Text('Cor da Etiqueta: ${tratamento.corEtiqueta}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Produtos:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.grey),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.green.shade100),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Produto', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Dosagem', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...tratamento.produtos.map((produto) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(produto['nome']!),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(produto['dosagem']!),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}