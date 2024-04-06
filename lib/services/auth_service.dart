import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Méthode pour écouter les changements d'état d'authentification
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Méthode pour s'inscrire avec email, mot de passe et nom d'utilisateur
  Future<User?> signUp(String email, String password, String username) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Mise à jour du nom d'utilisateur dans le profil de l'utilisateur
      await userCredential.user!.updateDisplayName(username);

      return userCredential.user;
    } catch (e) {
      print('Erreur lors de l\'inscription : $e');
      return null;
    }
  }

  // Méthode pour se connecter avec email et mot de passe
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Erreur lors de la connexion : $e');
      return null;
    }
  }

  // Méthode pour se déconnecter
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
