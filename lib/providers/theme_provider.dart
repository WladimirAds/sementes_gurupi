import 'package:flutter/material.dart';

import '../utils/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _temaAtual = temaPadrao; // Tema padrão inicial

  ThemeData get temaAtual => _temaAtual;

  void setTema(ThemeData tema) {
    _temaAtual = tema;
    notifyListeners(); // Notifica os ouvintes sobre a mudança
  }
}