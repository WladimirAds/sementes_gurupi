import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/beneficiamento_model.dart';

class BeneficiamentoEditavelScreen extends StatefulWidget {
  @override
  _BeneficiamentoEditavelScreenState createState() => _BeneficiamentoEditavelScreenState();
}

class _BeneficiamentoEditavelScreenState extends State<BeneficiamentoEditavelScreen> {
  final List<Beneficiamento> _beneficiamentos = [];
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _loteController = TextEditingController();
  final TextEditingController _cultivarController = TextEditingController();
  final TextEditingController _campoController = TextEditingController();
  final TextEditingController _qtdIdealController = TextEditingController();
  final TextEditingController _qtdRealController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _peneiraController = TextEditingController();
  final TextEditingController _cooperadoController = TextEditingController();
  final TextEditingController _qtdTotalController = TextEditingController();
  final TextEditingController _qtdSementesController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final List<TextEditingController> _repPmsControllers = List.generate(8, (index) => TextEditingController());
  final TextEditingController _pesoEnsaqueController = TextEditingController();
  final TextEditingController _pesoEtiquetaController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _safraController = TextEditingController();
  final TextEditingController _danoMecanicoController = TextEditingController();
  final TextEditingController _retencaoController = TextEditingController();
  final TextEditingController _umidadeController = TextEditingController();

  void _calcularPesoEtiqueta() {
    double soma = 0;
    int contador = 0;

    for (final controller in _repPmsControllers) {
      if (controller.text.isNotEmpty) {
        soma += double.tryParse(controller.text) ?? 0;
        contador++;
      }
    }

    if (contador == 8) {
      final mediaGramas = soma / 8;
      final mediaQuilos = mediaGramas / 1000; // Converte gramas para quilos
      _pesoEtiquetaController.text = mediaQuilos.toStringAsFixed(2); // Arredonda para 2 casas decimais
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Beneficiamento Editável')),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Lote')),
            DataColumn(label: Text('Cultivar')),
            DataColumn(label: Text('Campo')),
            DataColumn(label: Text('Qtd Ideal')),
            DataColumn(label: Text('Qtd Real')),
            DataColumn(label: Text('Categoria')),
            DataColumn(label: Text('Peneira')),
            DataColumn(label: Text('Cooperado')),
            DataColumn(label: Text('Qtd Total (Kg)')),
            DataColumn(label: Text('Qtd Sementes/Bag')),
            DataColumn(label: Text('Data')),
            DataColumn(label: Text('Rep PMs')),
            DataColumn(label: Text('Peso Ensaque')),
            DataColumn(label: Text('Peso Etiqueta')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Safra')),
            DataColumn(label: Text('Dano Mecânico')),
            DataColumn(label: Text('Retenção')),
            DataColumn(label: Text('Umidade')),
          ],
          rows: _beneficiamentos.map((beneficiamento) {
            return DataRow(cells: [
              DataCell(Text(beneficiamento.lote)),
              DataCell(Text(beneficiamento.cultivar)),
              DataCell(Text(beneficiamento.campo)),
              DataCell(Text(beneficiamento.qtdIdeal)),
              DataCell(Text(beneficiamento.qtdReal)),
              DataCell(Text(beneficiamento.categoria)),
              DataCell(Text(beneficiamento.peneira)),
              DataCell(Text(beneficiamento.cooperado)),
              DataCell(Text(beneficiamento.qtdTotal)),
              DataCell(Text(beneficiamento.qtdSementes)),
              DataCell(Text(beneficiamento.data)),
              DataCell(Text(beneficiamento.repPms)),
              DataCell(Text(beneficiamento.pesoEnsaque)),
              DataCell(Text(beneficiamento.pesoEtiqueta)),
              DataCell(Text(beneficiamento.status)),
              DataCell(Text(beneficiamento.safra)),
              DataCell(Text(beneficiamento.danoMecanico)),
              DataCell(Text(beneficiamento.retencao)),
              DataCell(Text(beneficiamento.umidade)),
            ]);
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddBeneficiamentoDialog(context, firestoreService);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddBeneficiamentoDialog(BuildContext context, FirestoreService firestoreService) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Beneficiamento'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _loteController,
                    decoration: InputDecoration(labelText: 'Lote'),
                  ),
                  TextFormField(
                    controller: _cultivarController,
                    decoration: InputDecoration(labelText: 'Cultivar'),
                  ),
                  TextFormField(
                    controller: _campoController,
                    decoration: InputDecoration(labelText: 'Campo'),
                  ),
                  TextFormField(
                    controller: _qtdIdealController,
                    decoration: InputDecoration(labelText: 'Qtd Ideal'),
                  ),
                  TextFormField(
                    controller: _qtdRealController,
                    decoration: InputDecoration(labelText: 'Qtd Real'),
                  ),
                  TextFormField(
                    controller: _categoriaController,
                    decoration: InputDecoration(labelText: 'Categoria'),
                  ),
                  TextFormField(
                    controller: _peneiraController,
                    decoration: InputDecoration(labelText: 'Peneira'),
                  ),
                  TextFormField(
                    controller: _cooperadoController,
                    decoration: InputDecoration(labelText: 'Cooperado'),
                  ),
                  TextFormField(
                    controller: _qtdTotalController,
                    decoration: InputDecoration(labelText: 'Qtd Total (Kg)'),
                  ),
                  TextFormField(
                    controller: _qtdSementesController,
                    decoration: InputDecoration(labelText: 'Qtd Sementes/Bag'),
                  ),
                  TextFormField(
                    controller: _dataController,
                    decoration: InputDecoration(labelText: 'Data'),
                  ),
                  SizedBox(height: 20),
                  Text('Repetições PMS (em gramas):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...List.generate(8, (index) {
                    return TextFormField(
                      controller: _repPmsControllers[index],
                      decoration: InputDecoration(labelText: 'Repetição ${index + 1}'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _calcularPesoEtiqueta(); // Calcula o peso da etiqueta ao alterar qualquer repetição
                      },
                    );
                  }),
                  TextFormField(
                    controller: _pesoEnsaqueController,
                    decoration: InputDecoration(labelText: 'Peso Ensaque'),
                  ),
                  TextFormField(
                    controller: _pesoEtiquetaController,
                    decoration: InputDecoration(labelText: 'Peso Etiqueta (kg)'),
                    readOnly: true, // Campo apenas para leitura
                  ),
                  TextFormField(
                    controller: _statusController,
                    decoration: InputDecoration(labelText: 'Status'),
                  ),
                  TextFormField(
                    controller: _safraController,
                    decoration: InputDecoration(labelText: 'Safra'),
                  ),
                  TextFormField(
                    controller: _danoMecanicoController,
                    decoration: InputDecoration(labelText: 'Dano Mecânico'),
                  ),
                  TextFormField(
                    controller: _retencaoController,
                    decoration: InputDecoration(labelText: 'Retenção'),
                  ),
                  TextFormField(
                    controller: _umidadeController,
                    decoration: InputDecoration(labelText: 'Umidade'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final repPms = _repPmsControllers.map((controller) => double.tryParse(controller.text) ?? 0).toList();
                        final beneficiamento = Beneficiamento(
                          lote: _loteController.text,
                          cultivar: _cultivarController.text,
                          campo: _campoController.text,
                          qtdIdeal: _qtdIdealController.text,
                          qtdReal: _qtdRealController.text,
                          categoria: _categoriaController.text,
                          peneira: _peneiraController.text,
                          cooperado: _cooperadoController.text,
                          qtdTotal: _qtdTotalController.text,
                          qtdSementes: _qtdSementesController.text,
                          data: _dataController.text,
                          repPms: repPms.join(', '), // Converte a lista de repetições em uma string
                          pesoEnsaque: _pesoEnsaqueController.text,
                          pesoEtiqueta: _pesoEtiquetaController.text,
                          status: _statusController.text,
                          safra: _safraController.text,
                          danoMecanico: _danoMecanicoController.text,
                          retencao: _retencaoController.text,
                          umidade: _umidadeController.text,
                        );

                        await firestoreService.addBeneficiamento(beneficiamento);
                        setState(() {
                          _beneficiamentos.add(beneficiamento);
                        });

                        Navigator.pop(context);
                      }
                    },
                    child: Text('Salvar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}