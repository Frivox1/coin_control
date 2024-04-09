import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coin_control/services/auth_service.dart';

class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({super.key});

  @override
  _NewTransactionScreenState createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  String? _selectedAccountName;
  double _transactionAmount = 0.0;
  final AuthService _authService = AuthService();
  bool _isPositive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Transaction', style: TextStyle(fontSize: 30)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60.0),
            FutureBuilder<List<String>>(
              future: _getAccounts(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No accounts found',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  );
                } else {
                  return Visibility(
                    visible: true,
                    child: DropdownButtonFormField<String>(
                      value: _selectedAccountName,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedAccountName = newValue;
                        });
                      },
                      items: snapshot.data!
                          .map<DropdownMenuItem<String>>((String accountName) {
                        return DropdownMenuItem<String>(
                          value: accountName,
                          child: Text(accountName),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        hintText: 'Select an account',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 60.0),
            Visibility(
              visible: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
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
                  const SizedBox(height: 60.0),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isPositive = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isPositive ? Colors.green : Colors.grey,
                            ),
                            child: const Text('+'),
                          ),
                        ),
                        const SizedBox(width: 60),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isPositive = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isPositive ? Colors.grey : Colors.red,
                            ),
                            child: const Text('-'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedAccountName != null) {
                    await _updateAccountBalance();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transaction completed successfully!'),
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Please select an account.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  textStyle: const TextStyle(
                    fontSize: 24,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 30,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
        .where('user_id', isEqualTo: _authService.getCurrentUserId())
        .get();
    List<String> accountNames = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      accountNames.add(data['account_name']);
    }
    return accountNames;
  }

  Future<void> _updateAccountBalance() async {
    String? userId = _authService.getCurrentUserId();
    if (userId != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('accounts')
          .where('account_name', isEqualTo: _selectedAccountName)
          .get();
      DocumentSnapshot accountSnapshot = querySnapshot.docs.first;
      DocumentReference accountRef = accountSnapshot.reference;

      await accountRef.update({
        'account_balance': _isPositive
            ? FieldValue.increment(_transactionAmount)
            : FieldValue.increment(-_transactionAmount)
      });
    }
  }
}
