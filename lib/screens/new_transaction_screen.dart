import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coin_control/services/auth_service.dart';

class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({Key? key}) : super(key: key);

  @override
  _NewTransactionScreenState createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  String? _selectedAccountId;
  // ignore: unused_field
  double _transactionAmount = 0.0;
  final AuthService _authService = AuthService();
  bool _isPositive =
      true; // Added to track if transaction amount is positive or negative

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Transaction', style: TextStyle(fontSize: 30)),
      ),
      body: Padding(
        padding: EdgeInsets.all(35.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60.0),
            FutureBuilder<List<String>>(
              future: _getAccounts(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    // Center the message
                    child: Text(
                      'No accounts found',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  );
                } else {
                  return Visibility(
                    visible:
                        true, // Show the dropdown only if there are accounts
                    child: DropdownButtonFormField<String>(
                      value: _selectedAccountId,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedAccountId = newValue;
                        });
                      },
                      items: snapshot.data!
                          .map<DropdownMenuItem<String>>((String accountId) {
                        return DropdownMenuItem<String>(
                          value: accountId,
                          child: Text(accountId),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        hintText: 'Select an account',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 30.0),
            Visibility(
              visible:
                  true, // Show the TextFormField only if there are accounts
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    _transactionAmount = double.parse(value);
                  });
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter the amount',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 30.0),
            Center(
              // Center the row
              child: Row(
                // Added Row to hold the buttons
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the buttons horizontally
                children: [
                  ElevatedButton(
                    // Button for positive amount
                    onPressed: () {
                      setState(() {
                        _isPositive = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPositive
                          ? Colors.green
                          : Colors.grey, // Change color based on selection
                    ),
                    child: Text('+'),
                  ),
                  SizedBox(width: 30), // Added space between buttons
                  ElevatedButton(
                    // Button for negative amount
                    onPressed: () {
                      setState(() {
                        _isPositive = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPositive
                          ? Colors.grey
                          : Colors.red, // Change color based on selection
                    ),
                    child: Text('-'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0), // Added space for better alignment
            SizedBox(
              // Added SizedBox to make the button as wide as the form
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
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
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                child: const Text('Confirm Transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _getAccounts() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('accounts')
        .where('user_id', isEqualTo: _authService.getCurrentUserId() as String)
        .get();
    List<String> accountNames = [];
    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      accountNames.add(data['account_name']);
    });
    return accountNames;
  }
}
