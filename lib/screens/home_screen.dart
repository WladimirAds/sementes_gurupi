import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sementes_gurupi/screens/configuracoes_screen.dart';
import '../services/auth_service.dart';
import 'estoque_screen.dart';
import 'beneficiamento_editavel_screen.dart';
import 'tratamento_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 colunas
            crossAxisSpacing: 10, // Espaçamento horizontal
            mainAxisSpacing: 10, // Espaçamento vertical
          ),
          children: [
            _buildHomeCard(
              context,
              icon: Icons.inventory,
              label: 'Estoque',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EstoqueScreen()),
                );
              },
            ),
            _buildHomeCard(
              context,
              icon: Icons.agriculture,
              label: 'Beneficiamento',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BeneficiamentoEditavelScreen(),
                  ),
                );
              },
            ),
            _buildHomeCard(
              context,
              icon: Icons.desktop_windows_sharp,
              label: 'Tratamento',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TratamentoScreen()),
                );
              },
            ),
            _buildHomeCard(
              context,
              icon: Icons.settings,
              label: 'Configurações',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfiguracoesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Theme.of(context).primaryColor),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
