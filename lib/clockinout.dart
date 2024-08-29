import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class ClockInOutPage extends StatefulWidget {
  const ClockInOutPage({super.key});

  @override
  ClockInOutPageState createState() => ClockInOutPageState();
}

class ClockInOutPageState extends State<ClockInOutPage> {
  final List<Map<String, dynamic>> _attendanceList = [];
  final List<String> _tasks = [
    'Complete project report',
    'Attend team meeting',
    'Review code submissions',
    'Plan next sprint',
    'Update project documentation',
    'Conduct code review',
    'Client follow-up call',
    'Prepare presentation',
    'Fix bugs reported in the morning',
    'Work on new feature implementation'
  ];

  @override
  void initState() {
    super.initState();
    _startNfcSession();  // Automatically start NFC session when the page loads
  }

  void _startNfcSession() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        Ndef? ndef = Ndef.from(tag);
        if (ndef == null) {
          throw 'NFC tag is not readable';
        }

        NdefMessage? message = ndef.cachedMessage;
        if (message == null) {
          throw 'No NDEF message found';
        }

        String data = message.records
            .map((record) => String.fromCharCodes(record.payload))
            .join();

        // Ensure the widget is still mounted before updating the state or using context
        if (mounted) {
          _processNfcData(data);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to read data: $e')),
          );
        }
        await NfcManager.instance.stopSession(errorMessage: e.toString());
      }
    });
  }

  void _processNfcData(String data) {
    final userDetails = data.split(',');

    if (userDetails.length < 2) {
      // Handle the case where the data is not in the expected format
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid NFC tag data. Expected "ID,Name" format.')),
      );
      return;
    }

    final userId = userDetails[0];
    final userName = userDetails[1];

    setState(() {
      final existingUser = _attendanceList.firstWhere(
        (user) => user['id'] == userId,
        orElse: () => {},
      );

      if (existingUser.isEmpty) {
        // New user - add clock-in time and show tasks
        _attendanceList.add({
          'id': userId,
          'name': userName,
          'clockIn': DateTime.now(),
          'clockOut': null,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$userName clocked in')),
        );
        _showTasksDialog(userName);
      } else if (existingUser['clockOut'] == null) {
        // Existing user - add clock-out time
        existingUser['clockOut'] = DateTime.now();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$userName clocked out')),
        );
      }
    });
  }

  void _showTasksDialog(String userName) {
    final randomTasks = _generateRandomTasks();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tasks for $userName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: randomTasks.map((task) => Text('- $task')).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    // Automatically close the dialog after 5 seconds
    Timer(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  List<String> _generateRandomTasks() {
    final random = Random();
    final shuffledTasks = _tasks..shuffle(random);
    return shuffledTasks.take(5).toList();
  }

  void _stopNfcSession() {
    NfcManager.instance.stopSession();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('NFC session stopped')),
    );
  }

  @override
  void dispose() {
    _stopNfcSession();  // Automatically stop NFC session when the page is closed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clock In/Out'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _attendanceList.length,
              itemBuilder: (context, index) {
                final user = _attendanceList[index];
                return ListTile(
                  title: Text('${user['name']}'),
                  subtitle: Text('Clock In: ${user['clockIn']}'
                      '${user['clockOut'] != null ? '\nClock Out: ${user['clockOut']}' : ''}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}