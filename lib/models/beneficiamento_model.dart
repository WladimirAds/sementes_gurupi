class Beneficiamento {
  String? id;
  final String lote;
  final String cultivar;
  final String campo;
  final String qtdIdeal;
  final String qtdReal;
  final String categoria;
  final String peneira;
  final String cooperado;
  final String qtdTotal;
  final String qtdSementes;
  final String data;
  final String repPms;
  final String pesoEnsaque;
  final String pesoEtiqueta;
  final String status;
  final String safra;
  final String danoMecanico;
  final String retencao;
  final String umidade;

  Beneficiamento({
    this.id,
    required this.lote,
    required this.cultivar,
    required this.campo,
    required this.qtdIdeal,
    required this.qtdReal,
    required this.categoria,
    required this.peneira,
    required this.cooperado,
    required this.qtdTotal,
    required this.qtdSementes,
    required this.data,
    required this.repPms,
    required this.pesoEnsaque,
    required this.pesoEtiqueta,
    required this.status,
    required this.safra,
    required this.danoMecanico,
    required this.retencao,
    required this.umidade,
  });

  Map<String, dynamic> toMap() {
    return {
      'lote': lote,
      'cultivar': cultivar,
      'campo': campo,
      'qtdIdeal': qtdIdeal,
      'qtdReal': qtdReal,
      'categoria': categoria,
      'peneira': peneira,
      'cooperado': cooperado,
      'qtdTotal': qtdTotal,
      'qtdSementes': qtdSementes,
      'data': data,
      'repPms': repPms,
      'pesoEnsaque': pesoEnsaque,
      'pesoEtiqueta': pesoEtiqueta,
      'status': status,
      'safra': safra,
      'danoMecanico': danoMecanico,
      'retencao': retencao,
      'umidade': umidade,
    };
  }

  static Beneficiamento fromMap(Map<String, dynamic> map, String id) {
    return Beneficiamento(
      id: id,
      lote: map['lote'],
      cultivar: map['cultivar'],
      campo: map['campo'],
      qtdIdeal: map['qtdIdeal'],
      qtdReal: map['qtdReal'],
      categoria: map['categoria'],
      peneira: map['peneira'],
      cooperado: map['cooperado'],
      qtdTotal: map['qtdTotal'],
      qtdSementes: map['qtdSementes'],
      data: map['data'],
      repPms: map['repPms'],
      pesoEnsaque: map['pesoEnsaque'],
      pesoEtiqueta: map['pesoEtiqueta'],
      status: map['status'],
      safra: map['safra'],
      danoMecanico: map['danoMecanico'],
      retencao: map['retencao'],
      umidade: map['umidade'],
    );
  }
}