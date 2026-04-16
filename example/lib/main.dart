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
  StreamSubscription<List<dynamic>>? _simCardsSubscription;
  Set<int> _trackedSubscriptionIds = <int>{};

  @override
  void initState() {
    super.initState();
    initSimInfo();
    _listenToSimChanges();
  }

  @override
  void dispose() {
    _simCardsSubscription?.cancel();
    super.dispose();
  }

  void _listenToSimChanges() {
    _simCardsSubscription = _simInfoPlugin.getSimCardsStream().listen((List<dynamic> simCards) {
      _logSimChange(simCards);
      if (!mounted) return;
      setState(() {
        _simCards = simCards;
      });
    });
  }

  Set<int> _extractSubscriptionIds(List<dynamic> simCards) {
    final Set<int> ids = <int>{};
    for (final dynamic sim in simCards) {
      if (sim is! Map) continue;
      final dynamic rawId = sim['subscriptionId'];
      if (rawId is int) {
        ids.add(rawId);
      } else if (rawId is num) {
        ids.add(rawId.toInt());
      } else if (rawId is String) {
        final int? parsed = int.tryParse(rawId);
        if (parsed != null) {
          ids.add(parsed);
        }
      }
    }
    return ids;
  }

  void _logSimChange(List<dynamic> simCards) {
    final Set<int> currentIds = _extractSubscriptionIds(simCards);
    final Set<int> removedIds = _trackedSubscriptionIds.difference(currentIds);
    final Set<int> addedIds = currentIds.difference(_trackedSubscriptionIds);

    if (removedIds.isNotEmpty) {
      debugPrint('SIM withdrawal detected. Removed subscriptionId(s): ${removedIds.join(', ')}');
    }
    if (addedIds.isNotEmpty) {
      debugPrint('SIM inserted/detected. New subscriptionId(s): ${addedIds.join(', ')}');
    }
    if (removedIds.isEmpty && addedIds.isEmpty) {
      debugPrint('SIM change event with no ID delta. Active SIM count: ${simCards.length}');
    }

    _trackedSubscriptionIds = currentIds;
  }

  Future<void> initSimInfo() async {
    List<dynamic> simCards;
    try {
      simCards = await _simInfoPlugin.getSimCardsDirect() ?? [];
    } on PlatformException {
      simCards = [];
    }

    if (!mounted) return;

    _trackedSubscriptionIds = _extractSubscriptionIds(simCards);
    debugPrint('Initial SIM snapshot loaded. Active SIM count: ${simCards.length}');

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
              subtitle: Text('Carrier: ${sim['carrierName']} | Slot: ${sim['slotIndex']} | Subscription ID: ${sim['subscriptionId']}'),
            );
          },
        ),
      ),
    );
  }
}
