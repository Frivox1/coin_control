import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coin_control/services/auth_service.dart';
import 'package:coin_control/screens/add_account_screen.dart';

class ListAccountsScreen extends StatelessWidget {
  const ListAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    Color getColorForAccountType(String accountType) {
      switch (accountType) {
        case 'Cash':
          return Colors.green;
        case 'Digital':
          return Colors.blue;
        case 'Investment':
          return Colors.orange;
        default:
          return Colors.black;
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'List of Accounts',
            style: TextStyle(color: Colors.black, fontSize: 30),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('accounts')
                .where('user_id',
                    isEqualTo: authService.getCurrentUserId() as String)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.black)),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No accounts found',
                      style: TextStyle(color: Colors.black, fontSize: 22)),
                );
              }

              return DataTable(
                columnSpacing: 40.0,
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text(
                      'Name',
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.black),
                    ),
                    numeric: false,
                    tooltip: 'Account Name',
                  ),
                  DataColumn(
                    label: Text(
                      'Type',
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.black),
                    ),
                    numeric: false,
                    tooltip: 'Account Type',
                  ),
                  DataColumn(
                    label: Text(
                      'Balance',
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.black),
                    ),
                    numeric: false,
                    tooltip: 'Account Balance',
                  ),
                  DataColumn(
                    label: Text(
                      'Action',
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.black),
                    ),
                    tooltip: 'Delete Account',
                  ),
                ],
                rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(
                        Text(
                          data['account_name'],
                          style: const TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          // Add your onTap logic here
                        },
                      ),
                      DataCell(
                        Text(
                          data['account_type'],
                          style: TextStyle(
                              color:
                                  getColorForAccountType(data['account_type'])),
                        ),
                        onTap: () {
                          // Add your onTap logic here
                        },
                      ),
                      DataCell(
                        Text(
                          data['account_balance'].toString(),
                          style: const TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          // Add your onTap logic here
                        },
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.black,
                                  title: const Text(
                                    'Confirm Delete',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: const Text(
                                    'Are you sure you want to delete this account?',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        document.reference.delete();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const AddAccountScreen();
            }));
          },
          label: const Text(
            '+ Add an account',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.black,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
