import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sementes_gurupi/providers/cultivar_provider.dart';
import 'package:sementes_gurupi/providers/lote_provider.dart';
import 'package:sementes_gurupi/providers/theme_provider.dart';
import 'package:sementes_gurupi/providers/tratamento_provider.dart';
import 'package:sementes_gurupi/screens/configuracoes_screen.dart';
import 'package:sementes_gurupi/screens/home_screen.dart';
import 'package:sementes_gurupi/screens/login_screen.dart';
import 'package:sementes_gurupi/screens/register_screen.dart';
import 'package:sementes_gurupi/screens/estoque_screen.dart';
import 'package:sementes_gurupi/services/auth_service.dart';
import 'package:sementes_gurupi/services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FirestoreService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle de Estoque',
      theme: themeProvider.temaAtual,
      home: HomeScreen(),
      routes: {
        '/login': (ctx) => RegisterScreen(),
        '/home': (ctx) => HomeScreen(),
        '/configuracoes': (ctx) => ConfiguracoesScreen(),
      },
    );
  }
}
