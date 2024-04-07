import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_account_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Coin Control',
          style: TextStyle(fontSize: 30),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu, size: 30),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Center(
                child: Text(
                  'Coin Control Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add, size: 24),
              title: const Text(
                'Add an account',
                style: TextStyle(fontSize: 24),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const AddAccountScreen();
                }));
              },
            ),
            ListTile(
              leading: const Icon(Icons.list, size: 24),
              title: const Text(
                'List of accounts',
                style: TextStyle(fontSize: 24),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, size: 24),
              title: const Text(
                'Settings',
                style: TextStyle(fontSize: 24),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, size: 24),
              title: const Text(
                'Sign out',
                style: TextStyle(fontSize: 24),
              ),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(
                    context, '/login'); // Redirection vers l'écran de connexion
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  if (snapshot.hasData) {
                    String username = snapshot.data!.displayName ?? 'Unknown';
                    return Text(
                      'Hi, $username',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  } else {
                    return const Text(
                      'User not signed in',
                      style: TextStyle(fontSize: 24),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 10),
            const Text(
              'Your current balance:',
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('accounts').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  double totalBalance = 0.0;
                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      totalBalance += (doc['account_balance'] ?? 0.0) as double;
                    }
                  }
                  return Text(
                    '${totalBalance.toStringAsFixed(2)}€',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add your onPressed functionality here
        },
        label: const Text(
          '+ Add a transaction',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
