
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/lote_model.dart';

class AddEditLoteScreen extends StatefulWidget {
  final Lote? lote;

  AddEditLoteScreen({this.lote});

  @override
  _AddEditLoteScreenState createState() => _AddEditLoteScreenState();
}

class _AddEditLoteScreenState extends State<AddEditLoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _loteController = TextEditingController();
  final TextEditingController _cultivarController = TextEditingController();
  final TextEditingController _campoController = TextEditingController();
  final TextEditingController _produtorController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _abreviacaoController = TextEditingController();
  final TextEditingController _corEtiquetaController = TextEditingController();
  final TextEditingController _fornecedorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.lote != null) {
      _loteController.text = widget.lote!.lote;
      _cultivarController.text = widget.lote!.cultivar;
      _campoController.text = widget.lote!.campo;
      _produtorController.text = widget.lote!.produtor;
      _categoriaController.text = widget.lote!.categoria;
      _abreviacaoController.text = widget.lote!.abreviacao;
      _corEtiquetaController.text = widget.lote!.corEtiqueta;
      _fornecedorController.text = widget.lote!.fornecedor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lote == null ? 'Adicionar Lote' : 'Editar Lote'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _loteController,
                  decoration: InputDecoration(labelText: 'Lote'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o lote';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _cultivarController,
                  decoration: InputDecoration(labelText: 'Cultivar'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o cultivar';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _campoController,
                  decoration: InputDecoration(labelText: 'Campo'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o campo';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _produtorController,
                  decoration: InputDecoration(labelText: 'Produtor'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o produtor';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _categoriaController,
                  decoration: InputDecoration(labelText: 'Categoria'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a categoria';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _abreviacaoController,
                  decoration: InputDecoration(labelText: 'Abreviação'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a abreviação';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _corEtiquetaController,
                  decoration: InputDecoration(labelText: 'Cor da Etiqueta'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a cor da etiqueta';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _fornecedorController,
                  decoration: InputDecoration(labelText: 'Fornecedor'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o fornecedor';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final lote = Lote(
                        id: widget.lote?.id,
                        lote: _loteController.text,
                        cultivar: _cultivarController.text,
                        campo: _campoController.text,
                        produtor: _produtorController.text,
                        categoria: _categoriaController.text,
                        abreviacao: _abreviacaoController.text,
                        corEtiqueta: _corEtiquetaController.text,
                        fornecedor: _fornecedorController.text,
                      );

                      if (widget.lote == null) {
                        await firestoreService.addLote(lote);
                      } else {
                        await firestoreService.updateLote(lote);
                      }

                      Navigator.pop(context);
                    }
                  },
                  child: Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}