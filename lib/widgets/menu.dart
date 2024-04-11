import 'package:coin_control/screens/analytics_screen.dart';
import 'package:coin_control/screens/list_transactions.dart';
import 'package:coin_control/screens/new_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:coin_control/screens/list_accounts_screen.dart';
import 'package:coin_control/screens/add_account_screen.dart';
import 'package:coin_control/services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Center(
              child: Text(
                'Coin Control Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
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
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const ListAccountsScreen();
              }));
            },
          ),
          ListTile(
            leading: const Icon(Icons.add, size: 24),
            title: const Text(
              'New transaction',
              style: TextStyle(fontSize: 24),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const NewTransactionScreen();
              }));
            },
          ),
          ListTile(
            leading: const Icon(Icons.list, size: 24),
            title: const Text(
              'List of transactions',
              style: TextStyle(fontSize: 24),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const ListTransactionsScreen();
              }));
            },
          ),
          ListTile(
              leading: const Icon(Icons.bar_chart, size: 24),
              title: const Text(
                'Analytics',
                style: TextStyle(fontSize: 24),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const AnalyticsScreen();
                }));
              }),
          ListTile(
            leading: const Icon(Icons.logout, size: 24),
            title: const Text(
              'Sign out',
              style: TextStyle(fontSize: 24),
            ),
            onTap: () {
              authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
