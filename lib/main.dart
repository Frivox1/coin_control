import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(CoinControl());
}

class CoinControl extends StatelessWidget {
  CoinControl({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coin Control',
      theme: ThemeData(
        brightness: Brightness.light, // Thème clair
        hintColor: Colors.black, // Couleur d'accentuation
        scaffoldBackgroundColor: Colors.white, // Fond de l'écran
        textTheme: const TextTheme(
          bodyLarge:
              TextStyle(color: Colors.black), // Couleur du texte principal
          bodyMedium:
              TextStyle(color: Colors.black), // Couleur du texte secondaire
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle:
              TextStyle(color: Colors.black), // Couleur du texte du label
          hintStyle:
              TextStyle(color: Colors.black), // Couleur du texte d'indication
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors
                    .black), // Couleur de la bordure lorsqu'elle est en focus
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors
                    .black), // Couleur de la bordure lorsqu'elle est activée
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor:
                Colors.black, // Couleur du texte des boutons surélevés
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // Couleur de la barre d'applications
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => StreamBuilder<User?>(
              stream: _authService.user,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  if (snapshot.data != null) {
                    return const HomeScreen();
                  } else {
                    return const LoginScreen();
                  }
                }
              },
            ),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
      },
    );
  }
}
