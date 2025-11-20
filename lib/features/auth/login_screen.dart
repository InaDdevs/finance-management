import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Cores da Marca
  static const Color primaryColor = Color(0xFF0D47A1); // Azul Escuro (similar ao logo)
  static const Color accentColor = Color(0xFF42A5F5); // Azul Claro (similar ao logo)

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    // Lógica de Login Aqui (por enquanto, apenas navega)
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Diálogo de Recuperação (mantido o original com a cor de fundo atualizada)
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
                const SizedBox(height: 24),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: accentColor.withOpacity(0.2), // Usa cor da marca
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () async {
                        const String url = 'https://accounts.google.com/signin/recovery';
                        final Uri googleRecoveryUrl = Uri.parse(url);

                        if (await canLaunchUrl(googleRecoveryUrl)) {
                          await launchUrl(googleRecoveryUrl, mode: LaunchMode.externalApplication);
                        }

                        Navigator.of(context).pop();
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
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
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Entendi', style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove o AppBar
      body: SingleChildScrollView( // Permite a rolagem em telas pequenas
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 64.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Logo FinTechPro
            Padding(
              padding: const EdgeInsets.only(top: 40.0, bottom: 40.0),
              child: Image.asset(
                'assets/fintechpro_logo.png', // **MUDAR PARA O CAMINHO CORRETO DO SEU ASSET**
                height: 200, // Aumentado para 180
              ),
            ),

            const Text(
              'Bem-vindo(a) de volta!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Faça login para gerenciar suas finanças.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),

            // 2. Campo E-mail
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-mail',
                prefixIcon: const Icon(Icons.email, color: accentColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: primaryColor, width: 2.0),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),

            // 3. Campo Senha
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: const Icon(Icons.lock, color: accentColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: primaryColor, width: 2.0),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),

            // 4. Esqueci a Senha
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showRecoveryDialog,
                child: const Text(
                  'Esqueci a Senha',
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 5. Botão Entrar
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 5,
              ),
              child: const Text(
                'ENTRAR',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 6. Criar Conta
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Não tem uma conta?",
                  style: TextStyle(fontSize: 14),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/register');
                  },
                  child: const Text(
                    'Cadastre-se',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}