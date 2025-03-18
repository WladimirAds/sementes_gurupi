import 'package:flutter/material.dart';

final ThemeData temaPadrao = ThemeData(
  primarySwatch: Colors.teal, // Tons de verde/azul acinzentado
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.grey[200],
  appBarTheme: AppBarTheme(
    color: Colors.teal[700],
  ),
);

final ThemeData temaClaro = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    color: Colors.blue,
  ),
);

final ThemeData temaEscuro = ThemeData(
  primarySwatch: Colors.indigo,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.grey[900],
  appBarTheme: AppBarTheme(
    color: Colors.indigo[700],
  ),
);