import 'package:flutter/material.dart';

final ThemeData temaPadrao = ThemeData(
  primarySwatch: Colors.lightGreen, // Tons de verde/azul acinzentado
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.teal[200],
  appBarTheme: AppBarTheme(
    color: Colors.teal,
  ),
);

final ThemeData temaClaro = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.blueGrey[200],
  appBarTheme: AppBarTheme(
    color: Colors.blue[800],
  ),
);

final ThemeData temaEscuro = ThemeData(
  primarySwatch: Colors.indigo,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.blueGrey[400],
  appBarTheme: AppBarTheme(
    color: Colors.indigo[700],
  ),
);