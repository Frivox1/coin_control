import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(fontSize: 30),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('accounts').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('No data available');
              }

              // Nombre de comptes par type
              Map<String, int> accountTypeCounts = {
                'Cash': 0,
                'Digital': 0,
                'Investment': 0,
              };

              // Calcul du nombre de comptes par type
              for (var doc in snapshot.data!.docs) {
                String accountType = doc['account_type'];
                if (accountTypeCounts.containsKey(accountType)) {
                  accountTypeCounts[accountType] =
                      (accountTypeCounts[accountType] ?? 0) + 1;
                }
              }

              // Création des données pour le graphique à barres
              final List<charts.Series<MapEntry<String, int>, String>>
                  barChartData = [
                charts.Series(
                  id: 'Account Count',
                  data: accountTypeCounts.entries.toList(),
                  domainFn: (entry, _) => entry.key,
                  measureFn: (entry, _) => entry.value,
                  colorFn: (entry, _) {
                    switch (entry.key) {
                      case 'Cash':
                        return charts.MaterialPalette.green.shadeDefault;
                      case 'Digital':
                        return charts.MaterialPalette.blue.shadeDefault;
                      case 'Investment':
                        return charts.MaterialPalette.deepOrange.shadeDefault;
                      default:
                        return charts.MaterialPalette.gray.shadeDefault;
                    }
                  },
                ),
              ];

              // Création du graphique à barres
              final barChart = charts.BarChart(
                barChartData,
                animate: true,
                vertical: true, // Affichage de bas en haut
                barGroupingType:
                    charts.BarGroupingType.grouped, // Centrage des colonnes
              );

              // Calcul du total des soldes par type de compte
              Map<String, double> accountTypeTotalBalances = {
                'Cash': 0,
                'Digital': 0,
                'Investment': 0,
              };

              // Calcul du total des soldes par type de compte
              for (var doc in snapshot.data!.docs) {
                String accountType = doc['account_type'];
                double? balance = (doc['account_balance'] as num?)?.toDouble();
                if (balance != null) {
                  accountTypeTotalBalances[accountType] =
                      (accountTypeTotalBalances[accountType] ?? 0) + balance;
                }
              }

              // Liste des textes pour chaque type de compte avec le montant total
              List<Widget> accountTypeBalancesList = accountTypeTotalBalances
                  .entries
                  .map((entry) => Text(
                        '${entry.key}: ${entry.value.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20, // Augmentation de la taille de police
                          color: _getColorForAccountType(entry.key),
                        ),
                      ))
                  .toList();

              // Création des données pour le graphique en camembert
              final List<charts.Series<MapEntry<String, double>, String>>
                  pieChartData = [
                charts.Series(
                  id: 'Account Balance',
                  data: accountTypeTotalBalances.entries.toList(),
                  domainFn: (entry, _) => entry.key,
                  measureFn: (entry, _) => entry.value,
                  colorFn: (entry, _) {
                    switch (entry.key) {
                      case 'Cash':
                        return charts.MaterialPalette.green.shadeDefault;
                      case 'Digital':
                        return charts.MaterialPalette.blue.shadeDefault;
                      case 'Investment':
                        return charts.MaterialPalette.deepOrange.shadeDefault;
                      default:
                        return charts.MaterialPalette.gray.shadeDefault;
                    }
                  },
                ),
              ];

              // Création du graphique en camembert
              final pieChart = charts.PieChart(
                pieChartData,
                animate: true,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Number of Accounts:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: barChart,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Total Balance by Account Type:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: accountTypeBalancesList,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Distribution of Account Balances:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: pieChart,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Fonction pour obtenir la couleur en fonction du type de compte
  Color _getColorForAccountType(String accountType) {
    switch (accountType) {
      case 'Cash':
        return Colors.green;
      case 'Digital':
        return Colors.blue;
      case 'Investment':
        return Colors.deepOrange;
      default:
        return Colors.black;
    }
  }
}
