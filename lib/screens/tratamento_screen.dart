import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/estoque_model.dart';
import '../services/firestore_service.dart';
import '../models/tratamento_model.dart';
import '../services/pdf_service.dart';
import 'pdf_viewer_screen.dart';

class TratamentoScreen extends StatefulWidget {
  @override
  _TratamentoScreenState createState() => _TratamentoScreenState();
}

class _TratamentoScreenState extends State<TratamentoScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Estoque> _filteredEstoque = [];
  bool _showSearshResults = false;
  String? _selectedLote;

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final pdfService = PdfService();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TRATAMENTO',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por lote, tratamento ou produtor',
                    prefixIcon: Icon(Icons.search_rounded),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) async {
                    setState(() {
                      _searchQuery = value;
                      _showSearshResults = value.isNotEmpty;
                    });
                    if (value.isNotEmpty) {
                      final estoques =
                          await firestoreService.getEstoques().first;

                      setState(() {
                        _filteredEstoque =
                            estoques.where((estoque) {
                              final lote = estoque.lote.toLowerCase();
                              final tratamento =
                                  estoque.tratado ? 'Tratado' : 'Não Tratado';
                              final produtor =
                                  estoque.produtor?.toLowerCase() ?? '';

                              return lote.contains(
                                    _searchQuery.toLowerCase(),
                                  ) ||
                                  tratamento.contains(
                                    _searchQuery.toLowerCase(),
                                  ) ||
                                  produtor.contains(_searchQuery.toLowerCase());
                            }).toList();
                      });
                    } else {
                      setState(() {
                        _filteredEstoque = [];
                      });
                    }
                  },
                ),
                // Lista flutuante de sugestões
                if (_showSearshResults && _filteredEstoque.isNotEmpty)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      itemCount: _filteredEstoque.length,
                      itemBuilder: (context, index) {
                        final estoque = _filteredEstoque[index];
                        return ListTile(
                          title: Text('Lote: ${estoque.lote}'),
                          subtitle: Text(
                            'Produtor: ${estoque.produtor ?? "N/A"}',
                          ),
                          onTap: () {
                            setState(() {
                              _searchController.text = estoque.lote;
                              _showSearshResults = false;
                            });
                            _showDetalhesLoteModal(
                              context,
                              estoque,
                              firestoreService,
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Tratamento>>(
              stream: firestoreService.getTratamentos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar tratamentos: ${snapshot.error}',
                    ),
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
          ),
        ],
      ),
      // FloatingActionButton para adicionar tratamento
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTratamentoDialog(context, firestoreService, pdfService);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // Modal para exibir detalhes do lote
  void _showDetalhesLoteModal(
    BuildContext context,
    Estoque estoque,
    FirestoreService firestoreService,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalhes do Lote'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lote: ${estoque.lote}'),
              Text('Câmara Fria: ${estoque.camaraFria}'),
              Text('Produtor: ${estoque.produtor ?? "N/A"}'),
              Text('Tratado: ${estoque.tratado ? 'Sim' : 'Não'}'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedLote = estoque.lote;
                    _searchController.clear();
                  });
                  Navigator.pop(context);
                  _showAddTratamentoDialog(
                    context,
                    firestoreService,
                    PdfService(),
                  );
                },
                child: Text('Selecionar Lote'),
              ),
              SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  // Diálogo para adicionar tratamento
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

  // Diálogo para editar tratamento
  void _showEditTratamentoDialog(
    BuildContext context,
    FirestoreService firestoreService,
    PdfService pdfService,
    Tratamento tratamento,
  ) {
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
    final TextEditingController _loteController = TextEditingController(
      text: _selectedLote ?? '',
    );
    final TextEditingController _maquinaController = TextEditingController();
    final TextEditingController _produtoController = TextEditingController();
    final TextEditingController _dosagemController = TextEditingController();
    final TextEditingController _corEtiquetaController =
        TextEditingController();
    final List<Map<String, String>> _produtos = [];

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
                            if (_maquinaController.text.isEmpty &&
                                value == null) {
                              return 'Por favor, selecione a máquina';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _produtoController,
                          decoration: InputDecoration(labelText: 'Produto'),
                        ),
                        TextFormField(
                          controller: _dosagemController,
                          decoration: InputDecoration(labelText: 'Dosagem'),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
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
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Preencha o produto e a dosagem!',
                                  ),
                                ),
                              );
                            }
                          },

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
                                          setState(() {
                                            _produtos.remove(produto);
                                          });
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

  // Função para retornar a cor da máquina
  Color _getCorMaquina(String maquina) {
    switch (maquina) {
      case 'BAYER':
        return Color(0xFF0D47A1);
      case 'SYNGENTA':
        return Color(0xFFB71C1C);
      case 'BASF':
        return Color(0xFF1B5E20);
      case 'CORTEVA':
        return Color(0xFF4A148C);
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      color: Colors.green[400],
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
                title: Text(
                  'Lote: ${widget.tratamento.lote}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                // Qual máquina está sendo feito o tratamento
                subtitle: Text(
                  '${widget.tratamento.maquina}',
                  style: TextStyle(
                    fontSize: 16,
                    color: _getCorMaquina(widget.tratamento.maquina),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.picture_as_pdf, color: Colors.blueGrey),
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
                      icon: Icon(Icons.edit, color: Colors.blueGrey),
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
                              content: Text(
                                'Erro: ID do tratamento não encontrado!',
                              ),
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
                      Row(
                        children: [
                          Text(
                            'Cor da Etiqueta: ',
                            style: TextStyle(fontSize: 16),
                          ),
                          Container(
                            width: 40,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _getCorMaquina(widget.tratamento.maquina),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Status: ${widget.tratamento.status}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          if (widget.tratamento.status == 'Soja Tratada') {
                            // Exibe um diálogo com os detalhes do tratamento
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Soja já tratada'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Lote: ${widget.tratamento.lote}'),
                                      Text(
                                        'Máquina: ${widget.tratamento.maquina}',
                                      ),
                                      Text(
                                        'Cor da Etiqueta: ${widget.tratamento.corEtiqueta}',
                                      ),
                                      Text(
                                        'Status: ${widget.tratamento.status}',
                                      ),
                                      SizedBox(height: 10),
                                      Text('Produtos:'),
                                      ...widget.tratamento.produtos.map((
                                        produto,
                                      ) {
                                        return Text(
                                          '- ${produto['nome']} (Dosagem: ${produto['dosagem']})',
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Fechar'),
                                    ),
                                  ],
                                );
                              },
                            );
                            return; // Impede a atualização do status
                          }
                          String novoStatus = _proximoStatus(
                            widget.tratamento.status,
                          );
                          if (novoStatus == widget.tratamento.status) {
                            // Exibe uma mensagem se o status não puder ser atualizado
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Status não pode ser atualizado!',
                                ),
                              ),
                            );
                            return; // Impede a atualização do status
                          }
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
      case 'Soja Branca':
        return 'Separado para tratamento'; // Só permite mudar para "Separado para tratamento"
      case 'Separado para tratamento':
        return 'Soja em Tratamento';
      case 'Soja em Tratamento':
        return 'Soja Tratada';
      case 'Soja Tratada':
        return 'Soja Tratada'; // Não permite mudar de "Soja Tratada" para outro status
      default:
        return statusAtual; // Mantém o status atual se não for um dos casos acima
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
