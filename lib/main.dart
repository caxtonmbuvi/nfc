import 'package:flutter/material.dart';
import 'package:nfccards/clockinout.dart';
import 'package:nfccards/registration.dart';
void main() {
  runApp(const NfcCardManagerApp());
}

class NfcCardManagerApp extends StatelessWidget {
  const NfcCardManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC Clock-In/Clock-Out',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Clock-In/Clock-Out'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegistrationPage()),
                );
              },
              child: const Text('Register User to NFC Tag'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ClockInOutPage()),
                );
              },
              child: const Text('Clock In/Out'),
            ),
          ],
        ),
      ),
    );
  }
}