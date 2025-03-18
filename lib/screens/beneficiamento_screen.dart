import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/beneficiamento_model.dart';

class BeneficiamentoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Beneficiamento'),
      ),
      body: StreamBuilder<List<Beneficiamento>>(
        stream: firestoreService.getBeneficiamentos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar beneficiamentos'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum beneficiamento encontrado'));
          } else {
            final beneficiamentos = snapshot.data!;
            return ListView.builder(
              itemCount: beneficiamentos.length,
              itemBuilder: (context, index) {
                final beneficiamento = beneficiamentos[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  color: Colors.blueGrey[800],
                  child: ExpansionTile(
                    title: Text('Lote: ${beneficiamento.lote}'),
                    subtitle: Text('Cultivar: ${beneficiamento.cultivar}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Campo: ${beneficiamento.campo}', style: TextStyle(fontSize: 16)),
                            Text('Qtd Ideal: ${beneficiamento.qtdIdeal}', style: TextStyle(fontSize: 16)),
                            Text('Qtd Real: ${beneficiamento.qtdReal}', style: TextStyle(fontSize: 16)),
                            Text('Categoria: ${beneficiamento.categoria}', style: TextStyle(fontSize: 16)),
                            Text('Peneira: ${beneficiamento.peneira}', style: TextStyle(fontSize: 16)),
                            Text('Cooperado: ${beneficiamento.cooperado}', style: TextStyle(fontSize: 16)),
                            Text('Qtd Total: ${beneficiamento.qtdTotal}', style: TextStyle(fontSize: 16)),
                            Text('Qtd Sementes/Bag: ${beneficiamento.qtdSementes}', style: TextStyle(fontSize: 16)),
                            Text('Data: ${beneficiamento.data}', style: TextStyle(fontSize: 16)),
                            Text('Rep PMs: ${beneficiamento.repPms}', style: TextStyle(fontSize: 16)),
                            Text('Peso Ensaque: ${beneficiamento.pesoEnsaque}', style: TextStyle(fontSize: 16)),
                            Text('Peso Etiqueta: ${beneficiamento.pesoEtiqueta}', style: TextStyle(fontSize: 16)),
                            Text('Status: ${beneficiamento.status}', style: TextStyle(fontSize: 16)),
                            Text('Safra: ${beneficiamento.safra}', style: TextStyle(fontSize: 16)),
                            Text('Dano Mecânico: ${beneficiamento.danoMecanico}', style: TextStyle(fontSize: 16)),
                            Text('Retenção: ${beneficiamento.retencao}', style: TextStyle(fontSize: 16)),
                            Text('Umidade: ${beneficiamento.umidade}', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}