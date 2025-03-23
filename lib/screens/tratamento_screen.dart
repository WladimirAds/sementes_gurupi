import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/tratamento_model.dart';
import '../services/pdf_service.dart';
import 'pdf_viewer_screen.dart';

class TratamentoScreen extends StatefulWidget {
  @override
  _TratamentoScreenState createState() => _TratamentoScreenState();
}

class _TratamentoScreenState extends State<TratamentoScreen> {
  final TextEditingController _loteController = TextEditingController();
  final TextEditingController _maquinaController = TextEditingController();
  final TextEditingController _produtoController = TextEditingController();
  final TextEditingController _dosagemController = TextEditingController();
  final TextEditingController _corEtiquetaController = TextEditingController();
  final List<Map<String, String>> _produtos = [];

  void _adicionarProduto() {
    if (_produtoController.text.isNotEmpty &&
        _dosagemController.text.isNotEmpty) {
      setState(() {
        _produtos.add({
          'nome': _produtoController.text,
          'dosagem': _dosagemController.text,
        });
        _produtoController.clear();
        _dosagemController.clear();
      });
    }
  }

  void _removerProduto(int index) {
    setState(() {
      _produtos.removeAt(index);
    });
  }

  void _limparCampos() {
    _loteController.clear();
    _maquinaController.clear();
    _produtoController.clear();
    _dosagemController.clear();
    _corEtiquetaController.clear();
    _produtos.clear();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final pdfService = PdfService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Tratamento'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddTratamentoDialog(context, firestoreService, pdfService);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Tratamento>>(
        stream: firestoreService.getTratamentos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar tratamentos: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum tratamento encontrado'));
          } else {
            final tratamentos = snapshot.data!;
            return ListView.builder(
              itemCount: tratamentos.length,
              itemBuilder: (context, index) {
                final tratamento = tratamentos[index];
                return AnimatedCard(
                  key: ValueKey(tratamento.id),
                  tratamento: tratamento,
                  firestoreService: firestoreService,
                  pdfService: pdfService,
                  onEdit:
                      () => _showEditTratamentoDialog(
                        context,
                        firestoreService,
                        pdfService,
                        tratamento,
                      ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showAddTratamentoDialog(
    BuildContext context,
    FirestoreService firestoreService,
    PdfService pdfService,
  ) {
    _showTratamentoDialog(
      context: context,
      firestoreService: firestoreService,
      pdfService: pdfService,
      isEditing: false,
    );
  }

  void _showEditTratamentoDialog(
    BuildContext context,
    FirestoreService firestoreService,
    PdfService pdfService,
    Tratamento tratamento,
  ) {
    _loteController.text = tratamento.lote;
    _maquinaController.text = tratamento.maquina;
    _corEtiquetaController.text = tratamento.corEtiqueta;
    _produtos.clear();
    _produtos.addAll(tratamento.produtos);

    _showTratamentoDialog(
      context: context,
      firestoreService: firestoreService,
      pdfService: pdfService,
      isEditing: true,
      tratamento: tratamento,
    );
  }

  void _showTratamentoDialog({
    required BuildContext context,
    required FirestoreService firestoreService,
    required PdfService pdfService,
    required bool isEditing,
    Tratamento? tratamento,
  }) {
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
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
                        DropdownButtonFormField<String>(
                          items:
                              ['BASF', 'BAYER', 'CORTEVA', 'SYNGENTA'].map((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _maquinaController.text = value!;
                              _corEtiquetaController.text =
                                  value == 'BASF'
                                      ? 'VERDE'
                                      : value == 'BAYER'
                                      ? 'AZUL'
                                      : value == 'CORTEVA'
                                      ? 'ROXA'
                                      : 'VERMELHA';
                            });
                          },
                          decoration: InputDecoration(labelText: 'Máquina'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, selecione a máquina';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _produtoController,
                          decoration: InputDecoration(labelText: 'Produto'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira o produto';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _dosagemController,
                          decoration: InputDecoration(labelText: 'Dosagem'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira a dosagem';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        AnimatedButton(
                          onPressed: _adicionarProduto,
                          child: Text('Adicionar Produto'),
                        ),
                        SizedBox(height: 10),
                        _produtos.isEmpty
                            ? Text('Nenhum produto adicionado')
                            : Column(
                              children:
                                  _produtos.map((produto) {
                                    return ListTile(
                                      title: Text(
                                        '${produto['nome']} (Dosagem: ${produto['dosagem']})',
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          _removerProduto(
                                            _produtos.indexOf(produto),
                                          );
                                        },
                                      ),
                                    );
                                  }).toList(),
                            ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _limparCampos();
                          },
                          child: Text('Cancelar'),
                        ),
                        SizedBox(width: 8),
                        AnimatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (_produtos.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Adicione pelo menos um produto!',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final novoTratamento = Tratamento(
                                id: isEditing ? tratamento?.id : null,
                                lote: _loteController.text,
                                maquina: _maquinaController.text,
                                produtos: _produtos,
                                corEtiqueta: _corEtiquetaController.text,
                                status:
                                    isEditing
                                        ? tratamento?.status ?? 'Pendente'
                                        : 'Pendente',
                              );

                              if (isEditing) {
                                await firestoreService.updateTratamento(
                                  novoTratamento,
                                );
                              } else {
                                await firestoreService.addTratamento(
                                  novoTratamento,
                                );
                              }

                              final pdf = await pdfService
                                  .generateTratamentoPdf(novoTratamento);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Tratamento ${isEditing ? 'atualizado' : 'salvo'} e PDF gerado!',
                                  ),
                                ),
                              );

                              _limparCampos();
                              Navigator.pop(context);
                            }
                          },
                          child: Text(isEditing ? 'Atualizar' : 'Salvar'),
                        ),
                      ],
                    ),
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

class AnimatedCard extends StatefulWidget {
  final Tratamento tratamento;
  final FirestoreService firestoreService;
  final PdfService pdfService;
  final VoidCallback onEdit;

  const AnimatedCard({
    Key? key,
    required this.tratamento,
    required this.firestoreService,
    required this.pdfService,
    required this.onEdit,
  }) : super(key: key);

  @override
  _AnimatedCardState createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      color: Colors.blueGrey[800],
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: AnimatedSize(
          duration: Duration(milliseconds: 300),
          child: Column(
            children: [
              ListTile(
                title: Text('Lote: ${widget.tratamento.lote}'),
                subtitle: Text('Máquina: ${widget.tratamento.maquina}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.picture_as_pdf, color: Colors.white),
                      onPressed: () async {
                        final pdf = await widget.pdfService
                            .generateTratamentoPdf(widget.tratamento);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfViewerScreen(pdf: pdf),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.white),
                      onPressed: widget.onEdit,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        if (widget.tratamento.id != null) {
                          await widget.firestoreService.deleteTratamento(
                            widget.tratamento.id!,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tratamento deletado com sucesso!'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro: ID do tratamento não encontrado!'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cor da Etiqueta: ${widget.tratamento.corEtiqueta}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Status: ${widget.tratamento.status}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          String novoStatus = _proximoStatus(
                            widget.tratamento.status,
                          );
                          await widget.firestoreService.updateTratamento(
                            Tratamento(
                              id: widget.tratamento.id,
                              lote: widget.tratamento.lote,
                              maquina: widget.tratamento.maquina,
                              produtos: widget.tratamento.produtos,
                              corEtiqueta: widget.tratamento.corEtiqueta,
                              status: novoStatus,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Status atualizado!')),
                          );
                        },
                        child: Text('Atualizar Status'),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Produtos:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...widget.tratamento.produtos.map((produto) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '- ${produto['nome']} (Dosagem: ${produto['dosagem']})',
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _proximoStatus(String statusAtual) {
    switch (statusAtual) {
      case 'Separado para tratamento':
        return 'Soja em Tratamento';
      case 'Soja em Tratamento':
        return 'Soja Tratada';
      case 'Soja Tratada':
        return 'Soja Branca';
      default:
        return 'Separado para tratamento';
    }
  }
}

class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const AnimatedButton({Key? key, required this.onPressed, required this.child})
    : super(key: key);

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: ElevatedButton(onPressed: widget.onPressed, child: widget.child),
      ),
    );
  }
}
