import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/beneficiamento_model.dart';
import '../models/estoque_model.dart';
import '../models/tratamento_model.dart';

class PdfService {
  Future<pw.Document> generateTratamentoPdf(Tratamento tratamento) async {
    final pdf = pw.Document();

    // Define a cor de fundo com base na cor da etiqueta
    PdfColor backgroundColor;
    switch (tratamento.corEtiqueta) {
      case 'VERDE':
        backgroundColor = PdfColors.green;
        break;
      case 'AZUL':
        backgroundColor = PdfColors.blue;
        break;
      case 'ROXA':
        backgroundColor = PdfColors.purple;
        break;
      case 'VERMELHA':
        backgroundColor = PdfColors.red;
        break;
      default:
        backgroundColor = PdfColors.white;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            color: backgroundColor,
            padding: pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'Detalhes do Tratamento',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Lote: ${tratamento.lote}',
                  style: pw.TextStyle(fontSize: 18, color: PdfColors.white),
                ),
                pw.Text(
                  'Máquina: ${tratamento.maquina}',
                  style: pw.TextStyle(fontSize: 18, color: PdfColors.white),
                ),
                pw.Text(
                  'Cor da Etiqueta: ${tratamento.corEtiqueta}',
                  style: pw.TextStyle(fontSize: 18, color: PdfColors.white),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Produtos:',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                ...tratamento.produtos.map((produto) {
                  return pw.Text(
                    '- ${produto['nome']} (Dosagem: ${produto['dosagem']})',
                    style: pw.TextStyle(fontSize: 16, color: PdfColors.white),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  Future<pw.Document> generateEstoquePdf(Estoque estoque) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Estoque - Lote: ${estoque.lote}', style: pw.TextStyle(fontSize: 20)),
              pw.SizedBox(height: 10),
              pw.Text('Câmara Fria: ${estoque.camaraFria}'),
              pw.Text('Status: ${estoque.tratado ? 'Soja Tratada' : 'Soja Branca'}'),
              pw.SizedBox(height: 10),
              pw.Text('Detalhes:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text('Nenhum tratamento aplicado'), // Substitua por detalhes reais, se necessário
            ],
          );
        },
      ),
    );

    return pdf;
  }
}
