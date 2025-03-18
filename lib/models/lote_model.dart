class Lote {
  String? id;
  final String lote;
  final String cultivar;
  final String campo;
  final String produtor;
  final String categoria;
  final String abreviacao;
  final String corEtiqueta;
  final String fornecedor;

  Lote({
    this.id,
    required this.lote,
    required this.cultivar,
    required this.campo,
    required this.produtor,
    required this.categoria,
    required this.abreviacao,
    required this.corEtiqueta,
    required this.fornecedor,
  });

  Map<String, dynamic> toMap() {
    return {
      'lote': lote,
      'cultivar': cultivar,
      'campo': campo,
      'produtor': produtor,
      'categoria': categoria,
      'abreviacao': abreviacao,
      'corEtiqueta': corEtiqueta,
      'fornecedor': fornecedor,
    };
  }

  static Lote fromMap(Map<String, dynamic> map, String id) {
    return Lote(
      id: id,
      lote: map['lote'],
      cultivar: map['cultivar'],
      campo: map['campo'],
      produtor: map['produtor'],
      categoria: map['categoria'],
      abreviacao: map['abreviacao'],
      corEtiqueta: map['corEtiqueta'],
      fornecedor: map['fornecedor'],
    );
  }
}