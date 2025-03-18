class Cultivar {
  final String id;
  final String nomeFantasia;
  final String nomeRegistro;
  final String corEtiqueta;
  final String empresaFornecedora;
  final String categoria;
  final String abreviacao;

  Cultivar({
    required this.id,
    required this.nomeFantasia,
    required this.nomeRegistro,
    required this.corEtiqueta,
    required this.empresaFornecedora,
    required this.categoria,
    required this.abreviacao,
  });

  factory Cultivar.fromMap(Map<String, dynamic> data, String id) {
    return Cultivar(
      id: id,
      nomeFantasia: data['nomeFantasia'],
      nomeRegistro: data['nomeRegistro'],
      corEtiqueta: data['corEtiqueta'],
      empresaFornecedora: data['empresaFornecedora'],
      categoria: data['categoria'],
      abreviacao: data['abreviacao'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nomeFantasia': nomeFantasia,
      'nomeRegistro': nomeRegistro,
      'corEtiqueta': corEtiqueta,
      'empresaFornecedora': empresaFornecedora,
      'categoria': categoria,
      'abreviacao': abreviacao,
    };
  }
}