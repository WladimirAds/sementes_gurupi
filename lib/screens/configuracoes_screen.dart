import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sementes_gurupi/services/firestore_service.dart';
import '../providers/theme_provider.dart';
import '../utils/theme.dart';

class ConfiguracoesScreen extends StatefulWidget {
  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  File? _fotoPerfil;
  String? _nomeUsuario;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('Usuário logado: ${user.uid}');
      final firestoreService = Provider.of<FirestoreService>(
        context,
        listen: false,
      );
      final nomeUsuario = await firestoreService.getNomeUsuario(user.uid);
      print('Nome do usuário: $nomeUsuario');

      final isAdmin = await firestoreService.isAdmin(user.uid);
      print('É admin: $isAdmin');
      setState(() {
        _nomeUsuario = nomeUsuario;
        _isAdmin = isAdmin;
      });
    }else{
      print('Nenhum usuário logado');
    }
  }

  Future<void> _escolherFoto() async {
    final picker = ImagePicker();
    final pickerFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickerFile != null) {
      setState(() {
        _fotoPerfil = File(pickerFile.path);
      });
    }
  }

  Future<void> _removerFoto() async {
    setState(() {
      _fotoPerfil = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Configurações')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: _escolherFoto,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _fotoPerfil != null ? FileImage(_fotoPerfil!) : null,
                  child:
                      _fotoPerfil == null
                          ? Icon(Icons.camera_alt, size: 40)
                          : null,
                ),
              ),
              if (_fotoPerfil != null)
                TextButton(
                  onPressed: _removerFoto,
                  child: Text('Remover Foto'),
                ),
            ],
          ),
          Text('Usuário: $_nomeUsuario', style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          Text(
            'Nome do Usuário: $_nomeUsuario',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 20),
          if (_isAdmin) ...[
            Text(
              'Opções de Administrador:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text('Adicionar Usuário'),
              leading: Icon(Icons.person_add),
              onTap: () {
                // Navegar para a tela de adicionar usuário
              },
            ),
            ListTile(
              title: Text('Excluir Usuário'),
              leading: Icon(Icons.person_remove),
              onTap: () {
                // Navegar para a tela de excluir usuário
              },
            ),
          ],

          // Substitua pelo nome real
          SizedBox(height: 20),

          Text(
            'Selecione o tema:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ListTile(
            title: Text('Tema Padrão'),
            leading: Icon(Icons.color_lens, color: Colors.teal),
            onTap: () {
              themeProvider.setTema(temaPadrao);
            },
          ),
          ListTile(
            title: Text('Tema Claro'),
            leading: Icon(Icons.wb_sunny, color: Colors.blue),
            onTap: () {
              themeProvider.setTema(temaClaro);
            },
          ),
          ListTile(
            title: Text('Tema Escuro'),
            leading: Icon(Icons.nights_stay, color: Colors.indigo),
            onTap: () {
              themeProvider.setTema(temaEscuro);
            },
          ),
        ],
      ),
    );
  }
}
