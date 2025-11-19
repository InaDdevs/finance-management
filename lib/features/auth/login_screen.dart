// lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';
// ADICIONE ESTA LINHA SE VOCÊ JÁ INSTALOU O PACOTE 'url_launcher'
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Adicionando os controladores que faltavam no seu snippet
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    // Lógica de login (autenticação)
    // ...
    // Após o sucesso, navega para o dashboard
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  void dispose() {
    // É importante fazer o dispose dos controladores
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Comentário original: esqueci o meu cu
  void _showRecoveryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recuperação de Conta'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                  'Atenção:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'O processo de recuperação de conta está sendo configurado para ser feito através da sua conta Google vinculada.',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Em breve, ao clicar neste botão, você será direcionado para um fluxo de recuperação utilizando a autenticação do Google.',
                  style: TextStyle(fontStyle: FontStyle.normal),
                ),
                // >>> NOVO ESPAÇAMENTO E BOTÃO <<<
                const SizedBox(height: 24),

                // Trecho MODIFICADO para reduzir o tamanho e arredondar as bordas
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0), // Arredondamento
                    child: TextButton(
                      style: TextButton.styleFrom(
                        // Cor de fundo e controle de tamanho através do padding
                        backgroundColor: const Color(0xFFC0DAE5),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () async {
                        const String url = 'https://accounts.google.com/signin/recovery';
                        final Uri googleRecoveryUrl = Uri.parse(url);

                        if (await canLaunchUrl(googleRecoveryUrl)) {
                          await launchUrl(googleRecoveryUrl, mode: LaunchMode.externalApplication);
                        }

                        Navigator.of(context).pop(); // Fecha o diálogo
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min, // Ocupa o mínimo de largura
                        children: [
                          Icon(Icons.g_mobiledata, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
                            'Acessar Recuperação Google',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // FIM DA MODIFICAÇÃO
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Entendi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          // 2. Faz os filhos (como ElevatedButton) esticarem na horizontal
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            // Adicionando os campos de texto que faltavam
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 32),

            // Este botão será esticado para preencher a largura
            ElevatedButton(
              onPressed: _login,
              child: const Text('Entrar'),
            ),

            // 3. Centraliza os botões de texto horizontalmente // KAUAN AWOOO
            Center(
              child: TextButton(
                onPressed: _showRecoveryDialog,
                child: const Text('Esqueci a Senha'),
                // KAUAN AWOOO
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/register');
                },
                child: const Text('Criar Conta / Cadastre-se'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}