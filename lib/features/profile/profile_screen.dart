import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/dart/providers/auth_provider.dart';
import '../reports/reports_screen.dart';
import 'account_settings_screen.dart';

const Color _primaryColor = Color(0xFF273238);
const Color _secondaryColor = Color(0xFF4DD0E1);
const Color _accentColor = Color(0xFF273238);
const Color _backgroundColor = Color(0xFFFFFFFF);
const Color _cardColor = Color(0xFFF0F0F0);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = _accentColor,
    Color textColor = _accentColor,
    bool isLogout = false,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        elevation: 4,
        shadowColor: Colors.black12,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isLogout ? Colors.redAccent : iconColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: textColor.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Perfil e Configurações', style: TextStyle(color: Colors.white)),
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: _primaryColor,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _secondaryColor.withOpacity(0.5), width: 3),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: _secondaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  authProvider.userName ?? 'Usuário',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _accentColor,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  authProvider.userEmail ?? 'Email não informado',
                  style: TextStyle(
                    fontSize: 14,
                    color: _accentColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          _buildProfileMenuItem(
            context: context,
            icon: Icons.bar_chart,
            title: 'Relatórios',
            iconColor: _secondaryColor,
            textColor: _accentColor,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ReportsScreen()),
              );
            },
          ),
          _buildProfileMenuItem(
            context: context,
            icon: Icons.settings,
            title: 'Configurações da Conta',
            iconColor: _secondaryColor,
            textColor: _accentColor,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
              );
            },
          ),
          const SizedBox(height: 30),
          _buildProfileMenuItem(
            context: context,
            icon: Icons.logout,
            title: 'Sair',
            iconColor: Colors.redAccent,
            textColor: Colors.redAccent,
            isLogout: true,
            onTap: () {
              authProvider.logout();
            },
          ),
        ],
      ),
    );
  }
}