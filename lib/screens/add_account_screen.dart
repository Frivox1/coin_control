import 'package:coin_control/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  _AddAccountScreenState createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _accountName = '';
  String _selectedAccountType = 'Cash'; // Default value changed to 'Cash'
  double _accountBalance = 0.0;

  final List<String> _accountTypes = [
    'Cash',
    'Digital',
    'Investment'
  ]; // Account types

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Instance de Firestore

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add an Account', style: TextStyle(fontSize: 30)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Account Name',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(
                    color: Colors.black), // Couleur du texte de saisie
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the account name';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _accountName = value;
                  });
                },
              ),
              const SizedBox(height: 60), // Increased space
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Account Balance',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(
                    color: Colors.black), // Couleur du texte de saisie
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the account balance';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _accountBalance = double.parse(value);
                  });
                },
              ),
              const SizedBox(height: 60), // Increased space
              DropdownButtonFormField<String>(
                value: _selectedAccountType,
                items: _accountTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAccountType = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Account Type',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(
                    color: Colors.black), // Couleur du texte de sélection
                dropdownColor:
                    Colors.white, // Couleur de fond de la liste déroulante
              ),
              const SizedBox(height: 60), // Increased space
              SizedBox(
                // Added SizedBox to make the button as wide as the form
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Call a function to handle account creation with the entered data
                      _createAccount();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    textStyle: const TextStyle(
                      fontSize: 24,
                    ), // Button color
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 30,
                    ), // Padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                  ),
                  child: const Text('Add Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createAccount() {
    // Enregistrer les données du compte dans Firestore
    _firestore.collection("accounts").add({
      'account_name': _accountName,
      'account_type': _selectedAccountType,
      'account_balance': _accountBalance,
    }).then((_) {
      print('Account created successfully!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account added successfully!'),
          duration: Duration(seconds: 2), // Durée du SnackBar
          backgroundColor: Colors.green, // Change the color to green
        ),
      );
      Future.delayed(Duration(seconds: 2), () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return HomeScreen();
        }));
      });
    }).catchError((error) {
      print('Error creating account: $error');
    });
  }
}
