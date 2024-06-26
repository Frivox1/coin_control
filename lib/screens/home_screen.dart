import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coin_control/widgets/menu.dart';
import 'package:coin_control/services/auth_service.dart';
import 'package:coin_control/screens/new_transaction_screen.dart';
import 'package:coin_control/widgets/balance_evolution_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

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
      drawer: const AppDrawer(),
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
                    String greeting = _getGreeting();
                    return Text(
                      '$greeting, $username',
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
              stream: FirebaseFirestore.instance
                  .collection('accounts')
                  .where('user_id',
                      isEqualTo: authService.getCurrentUserId() as String)
                  .snapshots(),
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
            const SizedBox(height: 20),
            // Text explaining the balance history chart
            const Text(
              'Your account balance evolution:',
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 20),
            const BalanceEvolutionChart(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const NewTransactionScreen();
          }));
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

  String _getGreeting() {
    DateTime now = DateTime.now();
    if (now.hour < 12) {
      return 'Good Morning';
    } else if (now.hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
