import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    String _nfcMessage = 'No NFC Data';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC Card Project'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _writeNFC,
              child: Text('Write to NFC Card'),
            ),
            ElevatedButton(
              onPressed: _readNFC,
              child: Text('Read from NFC Card'),
            ),
            SizedBox(height: 20),
            Text(_nfcMessage),
          ],
        ),
      ),
    );
  }

  Future<void> _writeNFC() async {
    try {
      var result = await FlutterNfcKit.poll();
      await FlutterNfcKit.transceive('Some data to write');
      setState(() {
        _nfcMessage = 'Data written to NFC card!';
      });
    } catch (e) {
      setState(() {
        _nfcMessage = 'Error writing to NFC card: $e';
      });
    }
  }

  Future<void> _readNFC() async {
    try {
      var result = await FlutterNfcKit.poll();
      var nfcData = await FlutterNfcKit.transceive('Your read command');
      setState(() {
        _nfcMessage = 'NFC Data: $nfcData';
      });
      _showUserDetails(context, nfcData);
    } catch (e) {
      setState(() {
        _nfcMessage = 'Error reading NFC card: $e';
      });
    }
  }

  void _showUserDetails(BuildContext context, String nfcData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User Details'),
          content: Text('Details from NFC: $nfcData'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
