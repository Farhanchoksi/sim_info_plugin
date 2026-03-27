import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:sim_info_plugin/sim_info_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<dynamic> _simCards = [];
  final _simInfoPlugin = SimInfoPlugin();

  @override
  void initState() {
    super.initState();
    initSimInfo();
  }

  Future<void> initSimInfo() async {
    List<dynamic> simCards;
    try {
      simCards = await _simInfoPlugin.getSimCardsDirect() ?? [];
    } on PlatformException {
      simCards = [];
    }

    if (!mounted) return;

    setState(() {
      _simCards = simCards;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sim Info Plugin Example'),
        ),
        body: ListView.builder(
          itemCount: _simCards.length,
          itemBuilder: (context, index) {
            final sim = _simCards[index];
            return ListTile(
              leading: const Icon(Icons.sim_card),
              title: Text(sim['number'].toString().isNotEmpty ? sim['number'].toString() : 'No Number'),
              subtitle: Text('Carrier: ${sim['carrierName']} | Slot: ${sim['slotIndex']}'),
            );
          },
        ),
      ),
    );
  }
}
