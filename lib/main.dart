import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      AuthService authService = AuthService();
      String userId = authService.getCurrentUserId() ?? '';

      QuerySnapshot accountSnapshot = await FirebaseFirestore.instance
          .collection('accounts')
          .where('user_id', isEqualTo: userId)
          .get();

      double totalBalance = 0.0;
      for (var doc in accountSnapshot.docs) {
        totalBalance += (doc['account_balance'] ?? 0.0) as double;
      }

      await FirebaseFirestore.instance.collection('balance_history').add({
        'user_id': userId,
        'total_balance': totalBalance,
        'timestamp': Timestamp.now(),
      });

      return Future.value(true);
    } catch (e) {
      // ignore: avoid_print
      print('Error executing background task: $e');
      return Future.value(false);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize WorkManager
  Workmanager workmanager = Workmanager();
  workmanager.initialize(callbackDispatcher, isInDebugMode: false);

  // Initialize timezone data
  tzdata.initializeTimeZones();

  // Get the local timezone name
  String timeZoneName = tz.local.name;

  // Get the current time in the local timezone
  tz.TZDateTime now = tz.TZDateTime.now(tz.getLocation(timeZoneName));

  // Calculate the next Sunday at midnight
  tz.TZDateTime nextSunday = tz.TZDateTime(
      tz.local, now.year, now.month, now.day + (7 - now.weekday), 0, 0);

  // Register a one-off task to trigger every Sunday at 00:00 local time
  workmanager.registerOneOffTask(
    "1",
    "updateData",
    initialDelay:
        Duration(milliseconds: nextSunday.difference(now).inMilliseconds),
  );

  runApp(CoinControl());
}

class CoinControl extends StatelessWidget {
  CoinControl({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coin Control',
      theme: ThemeData(
          // Theme data
          ),
      initialRoute: '/',
      routes: {
        '/': (context) => StreamBuilder<User?>(
              stream: _authService.user,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  if (snapshot.data != null) {
                    return const HomeScreen();
                  } else {
                    return const LoginScreen();
                  }
                }
              },
            ),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
      },
    );
  }
}
