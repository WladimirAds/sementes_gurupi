import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  Future<void> _cadastrarUsuario(BuildContext context) async {
    final email = _emailController.text.trim();
    final senha = _passwordController.text.trim();
    final nome = _nameController.text.trim();

    if (email.isEmpty || senha.isEmpty || nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos!')),
      );
      return;
    }

    try {
      // Cria o usuário no Firebase Auth
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Obtém o usuário criado
      final user = userCredential.user;
      if (user != null) {
        // Adiciona os dados do usuário na coleção "usuarios" no Firestore
        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
          'nome': nome,
          'email': email,
          'isAdmin': false, // Define como false por padrão
        });

        print('Usuário cadastrado com sucesso! ID: ${user.uid}');

        // Navega para a tela de configurações
        Navigator.of(context).pushReplacementNamed('/configuracoes');
      }
    } catch (e) {
      print('Erro ao cadastrar usuário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: $e')),
      );
    }
  }

   @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo com curvas
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.shade50,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          'Sementes Gurupi',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'MG Seeds',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 40),
                TextField(
                  style: TextStyle(color: Colors.black),
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  style: TextStyle(color: Colors.black),
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Sobrenome',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  style: TextStyle(color: Colors.black),
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  style: TextStyle(color: Colors.black),
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final email = _emailController.text;
                      final password = _passwordController.text;
                      final name = _nameController.text;
                      final lastName = _lastNameController.text;
                      await authService.registerWithEmailAndPassword(email, password, name, lastName);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      'Cadastrar',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    'Já tem uma conta? Faça login',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}