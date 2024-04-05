import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart'; // Import the AuthService

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService(); // Instantiate the AuthService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          // Logout button
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Call the signOut method from AuthService
              await _authService.signOut();
              // Redirect to the login screen
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome Home!'),
            SizedBox(height: 20),
            // StreamBuilder to listen for changes in user authentication state
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  if (snapshot.hasData) {
                    // User is signed in, display the user's email
                    String userEmail = snapshot.data!.email ?? 'Unknown';
                    return Text('Email: $userEmail');
                  } else {
                    // User is signed out
                    return Text('User not signed in');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
