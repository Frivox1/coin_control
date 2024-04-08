import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BalanceEvolutionChart extends StatelessWidget {
  const BalanceEvolutionChart({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('balance_history')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          List<BalanceData> data = snapshot.data!.docs.map((doc) {
            return BalanceData(
              DateTime.fromMillisecondsSinceEpoch(
                  doc['timestamp'].millisecondsSinceEpoch),
              doc['total_balance'].toDouble(),
            );
          }).toList();

          data = data.reversed.toList();

          return Container(
            height: 300,
            padding: const EdgeInsets.all(16.0),
            child: charts.TimeSeriesChart(
              [
                charts.Series<BalanceData, DateTime>(
                  id: 'Balance',
                  colorFn: (_, __) => charts.ColorUtil.fromDartColor(
                      Colors.black), // Changer la couleur de la ligne en noir
                  domainFn: (BalanceData balance, _) => balance.date,
                  measureFn: (BalanceData balance, _) => balance.balance,
                  data: data,
                  labelAccessorFn: (BalanceData balance, _) =>
                      DateFormat('dd/MM/yyyy').format(balance.date),
                ),
              ],
              defaultRenderer: charts.LineRendererConfig(includePoints: true),
              animate: true,
              animationDuration: const Duration(milliseconds: 500),
              primaryMeasureAxis: const charts.NumericAxisSpec(
                tickProviderSpec: charts.BasicNumericTickProviderSpec(
                  desiredTickCount: 5,
                ),
              ),
              domainAxis: const charts.DateTimeAxisSpec(
                renderSpec: charts.NoneRenderSpec(),
              ),
            ),
          );
        }
      },
    );
  }
}

class BalanceData {
  final DateTime date;
  final double balance;

  BalanceData(this.date, this.balance);
}
