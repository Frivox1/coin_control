import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BalanceEvolutionChart extends StatelessWidget {
  const BalanceEvolutionChart({Key? key});

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
                  colorFn: (balance, _) => _getColor(balance, data),
                  domainFn: (balance, _) => balance.date,
                  measureFn: (balance, _) => balance.balance,
                  data: data,
                  labelAccessorFn: (balance, _) =>
                      DateFormat('dd/MM/yyyy').format(balance.date),
                  fillColorFn: (balance, _) => _getPointColor(balance, data),
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

  charts.Color _getColor(BalanceData balance, List<BalanceData> data) {
    final index = data.indexOf(balance);
    if (index == data.length - 1) {
      return charts.ColorUtil.fromDartColor(Colors.black);
    }

    double nextBalance = data[index + 1].balance;
    double currentBalance = balance.balance;

    if (currentBalance > nextBalance) {
      return charts.ColorUtil.fromDartColor(Colors.red);
    } else if (currentBalance < nextBalance) {
      return charts.ColorUtil.fromDartColor(Colors.green);
    } else {
      return charts.ColorUtil.fromDartColor(Colors.black);
    }
  }

  charts.Color _getPointColor(BalanceData balance, List<BalanceData> data) {
    final lineColor = _getColor(balance, data);

    if (lineColor == charts.ColorUtil.fromDartColor(Colors.red)) {
      return charts.ColorUtil.fromDartColor(Colors.green);
    } else if (lineColor == charts.ColorUtil.fromDartColor(Colors.green)) {
      return charts.ColorUtil.fromDartColor(Colors.red);
    } else {
      return charts.ColorUtil.fromDartColor(Colors.black);
    }
  }
}

class BalanceData {
  final DateTime date;
  final double balance;

  BalanceData(this.date, this.balance);
}
