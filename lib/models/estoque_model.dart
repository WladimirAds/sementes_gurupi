class Estoque {
  final String id;
  final String lote;
  final String camaraFria;
  final bool tratado;
  final String? produtor; // Campo opcional

  Estoque({
    required this.id,
    required this.lote,
    required this.camaraFria,
    required this.tratado,
    this.produtor, // Valor padrão para evitar erros
  });

  factory Estoque.fromMap(Map<String, dynamic> data, String id) {
    return Estoque(
      id: id,
      lote: data['lote'],
      camaraFria: data['camaraFria'],
      tratado: data['tratado'] ?? false,
      produtor: data['produtor'], // Valor padrão se o campo não existir
    );
  }
}