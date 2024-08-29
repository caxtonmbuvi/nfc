import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  RegistrationPageState createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  NfcTag? _currentTag;
  bool _isWriting = false;
  bool _isDialogOpen = false;

  // Dummy user data
  final List<User> _users = [
    User(id: '1', name: 'John Doe', email: 'john.doe@example.com'),
    User(id: '2', name: 'Jane Smith', email: 'jane.smith@example.com'),
    User(id: '3', name: 'Alice Johnson', email: 'alice.johnson@example.com'),
    User(id: '4', name: 'Bob Brown', email: 'bob.brown@example.com'),
  ];

  String userId = '';
  String userName = '';

  void _startNfcSession() async {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      if (!mounted || _isWriting || userId.isEmpty || userName.isEmpty) return;

      setState(() {
        _currentTag = tag;
        _isWriting = true; // Prevent multiple writes
      });

      _writeToNfc(userId, userName); // Write data to the tag
    });
  }

  void _showInputDialog(User user) {
    setState(() {
      userId = user.id;
      userName = user.name;
    });

    _isDialogOpen = true;
    _startNfcSession();  // Automatically start the NFC session when the dialog opens

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Register User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: userId),
                decoration: const InputDecoration(hintText: "Enter User ID"),
                readOnly: true,
              ),
              TextField(
                controller: TextEditingController(text: userName),
                decoration: const InputDecoration(hintText: "Enter User Name"),
                readOnly: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _isDialogOpen = false;
                _stopNfcSession();  // Stop session if user cancels
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    ).then((_) {
      if (_isDialogOpen && mounted) {
        _stopNfcSession();
      }
    });
  }

  void _writeToNfc(String userId, String userName) async {
    if (_currentTag == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No NFC tag detected. Please try again.')),
        );
      }
      return;
    }

    final message = NdefMessage([
      NdefRecord.createText('$userId,$userName'),
    ]);

    try {
      log("Starting NFC write operation...");

      final ndef = Ndef.from(_currentTag!);
      if (ndef == null || !ndef.isWritable) {
        throw 'NFC tag is not writable';
      }

      log("Writing new data: User ID = $userId, User Name = $userName");
      await ndef.write(message);

      if (mounted) {
        log("Data written successfully.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User details written to NFC tag successfully!')),
        );
        Navigator.of(context).pop(); // Close the dialog and navigate back
      }
    } catch (e) {
      log("Error during NFC write operation: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to write data: $e')),
        );
      }
    } finally {
      _stopNfcSession();
    }
  }

  void _stopNfcSession() async {
    await NfcManager.instance.stopSession();
    if (mounted) {
      setState(() {
        _currentTag = null;
        _isWriting = false;
        _isDialogOpen = false;
      });
    }
  }

  @override
  void dispose() {
    _stopNfcSession();  // Ensure the session is stopped when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Registration'),
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            title: Text(user.name),
            subtitle: Text(user.email),
            onTap: () => _showInputDialog(user), // Show the prefilled dialog
          );
        },
      ),
    );
  }
}


