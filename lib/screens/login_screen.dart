import 'package:coin_control/screens/signup_screen';
import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Importez votre service d'authentification

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  // Définissez les contrôleurs pour les champs d'entrée
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Logique pour se connecter
                  String email = _emailController.text.trim();
                  String password = _passwordController.text.trim();

                  // Appel à la méthode de connexion dans le service d'authentification
                  dynamic result = await _authService.signIn(email, password);

                  // Vérifiez le résultat et gérez-le en conséquence
                  if (result != null) {
                    // L'utilisateur est connecté avec succès
                    // Vous pouvez rediriger l'utilisateur vers une autre page, par exemple la page d'accueil
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    // Une erreur s'est produite lors de la connexion
                    // Vous pouvez afficher un message d'erreur à l'utilisateur
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de la connexion')),
                    );
                  }
                },
                child: Text('Login'),
              ),
              SizedBox(height: 20),
              // Ajoutez un lien vers l'écran d'inscription
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                child: Text(
                  'Pas encore inscrit ? Inscrivez-vous ici',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Disposez des contrôleurs pour éviter les fuites de mémoire
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
