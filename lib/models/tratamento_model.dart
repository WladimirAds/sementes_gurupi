class Tratamento {
  String? id;
  final String lote;
  final String maquina;
  final List<Map<String, String>> produtos;
  final String corEtiqueta;
  final String status;

  Tratamento({
    this.id,
    required this.lote,
    required this.maquina,
    required this.produtos,
    required this.corEtiqueta,
    this.status = 'Pendente',
  });

  Map<String, dynamic> toMap() {
    return {
      'lote': lote,
      'maquina': maquina,
      'produtos': produtos,
      'corEtiqueta': corEtiqueta,
    };
  }

  static Tratamento fromMap(Map<String, dynamic> map, String id) {
    return Tratamento(
      id: id,
      lote: map['lote'],
      maquina: map['maquina'],
      produtos: List<Map<String, String>>.from(map['produtos']),
      corEtiqueta: map['corEtiqueta'],
    );
  }
}