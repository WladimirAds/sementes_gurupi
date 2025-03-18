import 'package:flutter/material.dart';
import '../models/lote_model.dart';

class LoteDetailScreen extends StatelessWidget {
  final Lote lote;

  LoteDetailScreen({required this.lote});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalhes do Lote')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lote: ${lote.lote}'),
            Text('Cultivar: ${lote.cultivar}'),
            Text('Campo: ${lote.campo}'),
            Text('Produtor: ${lote.produtor}'),
            Text('Categoria: ${lote.categoria}'),
            Text('Abreviação: ${lote.abreviacao}'),
            Text('Cor da Etiqueta: ${lote.corEtiqueta}'),
            Text('Fornecedor: ${lote.fornecedor}'),
          ],
        ),
      ),
    );
  }
}