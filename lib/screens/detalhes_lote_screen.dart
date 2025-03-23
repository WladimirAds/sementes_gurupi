import 'package:flutter/material.dart';
import '../models/estoque_model.dart';

class DetalhesLoteScreen extends StatelessWidget {
  final Estoque estoque;

  const DetalhesLoteScreen({Key? key, required this.estoque}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Lote'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lote: ${estoque.lote}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Câmara Fria: ${estoque.camaraFria}'),
            Text('Tratado: ${estoque.tratado ? 'Sim' : 'Não'}'),
            Text('Produtor: ${estoque.produtor}'), // Adicione outros campos conforme necessário
          ],
        ),
      ),
    );
  }
}