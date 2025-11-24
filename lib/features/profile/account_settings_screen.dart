import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/dart/providers/auth_provider.dart';

const Color _primaryColor = Color(0xFF626C75);
const Color _accentColor = Color(0xFF4DD0E1);
const Color _cardColor = Color(0xFFF5F5F5);

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  Future<void> _updateProfileData({String? newName, String? newEmail, String? newPassword, String? currentPassword}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;
    String currentEmail = authProvider.userEmail ?? '';

    if (newPassword != null && currentPassword != null && currentEmail.isNotEmpty) {
      success = await authProvider.updateUserPassword(currentEmail, currentPassword, newPassword);
      if (success) {
        _showSnackbar('Senha alterada com sucesso!');
      } else {
        _showSnackbar('Falha ao alterar senha. Verifique sua senha atual.', isError: true);
      }
    } else if (newName != null && newName.isNotEmpty) {
      success = await authProvider.updateUserName(newName);
      if (success) {
        _showSnackbar('Nome alterado com sucesso!');
      } else {
        _showSnackbar('Falha ao alterar nome.', isError: true);
      }
    } else if (newEmail != null && newEmail.contains('@')) {
      success = await authProvider.updateUserEmail(newEmail);
      if (success) {
        _showSnackbar('E-mail alterado com sucesso! Requer novo login.', isError: true);
      } else {
        _showSnackbar('Falha ao alterar e-mail. O e-mail pode já estar em uso.', isError: true);
      }
    }

    if (success || newPassword != null) {
      Navigator.of(context).pop();
    }
  }

  void _showNameModal(String currentName) {
    _nameController.text = currentName;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alterar Nome'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Novo Nome'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  _updateProfileData(newName: _nameController.text);
                }
              },
              child: const Text('Salvar', style: TextStyle(color: _primaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _showEmailModal(String currentEmail) {
    _emailController.text = currentEmail;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alterar E-mail'),
          content: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Novo E-mail'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                if (_emailController.text.contains('@')) {
                  _updateProfileData(newEmail: _emailController.text);
                } else {
                  _showSnackbar('Insira um e-mail válido.', isError: true);
                }
              },
              child: const Text('Salvar', style: TextStyle(color: _primaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _showPasswordModal() {
    _currentPasswordController.clear();
    _newPasswordController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alterar Senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha Atual'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nova Senha'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                if (_newPasswordController.text.length >= 6) {
                  _updateProfileData(
                    newPassword: _newPasswordController.text,
                    currentPassword: _currentPasswordController.text,
                  );
                } else {
                  _showSnackbar('A nova senha deve ter no mínimo 6 caracteres.', isError: true);
                }
              },
              child: const Text('Salvar', style: TextStyle(color: _primaryColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserName = authProvider.userName ?? 'N/A';
    final currentUserEmail = authProvider.userEmail ?? 'N/A';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Configurações da Conta', style: TextStyle(color: Colors.white)),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: _cardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nome: $currentUserName', style: const TextStyle(fontSize: 16)),
                  const Divider(),
                  Text('E-mail: $currentUserEmail', style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.person, color: _primaryColor),
            title: const Text('Alterar Nome'),
            trailing: const Icon(Icons.edit, color: _accentColor),
            onTap: () => _showNameModal(currentUserName),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: _primaryColor.withOpacity(0.2)),
            ),
            tileColor: _cardColor,
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.email, color: _primaryColor),
            title: const Text('Alterar E-mail'),
            trailing: const Icon(Icons.edit, color: _accentColor),
            onTap: () => _showEmailModal(currentUserEmail),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: _primaryColor.withOpacity(0.2)),
            ),
            tileColor: _cardColor,
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.lock, color: _primaryColor),
            title: const Text('Alterar Senha'),
            trailing: const Icon(Icons.chevron_right, color: _accentColor),
            onTap: _showPasswordModal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: _primaryColor.withOpacity(0.2)),
            ),
            tileColor: _cardColor,
          ),
        ],
      ),
    );
  }
}