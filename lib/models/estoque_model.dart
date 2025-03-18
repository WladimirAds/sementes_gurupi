class Estoque {
  final String id;
  final String lote;
  final String camaraFria;
  final bool tratado;

  Estoque({
    required this.id,
    required this.lote,
    required this.camaraFria,
    this.tratado = false,
  });
}
