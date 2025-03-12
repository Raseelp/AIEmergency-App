import 'package:flutter/material.dart';

import 'Pages/ipset.dart';

void main() {
  runApp(const Ambulance());
}

class Ambulance extends StatefulWidget {
  const Ambulance({super.key});

  @override
  State<Ambulance> createState() => _AmbulanceState();
}

class _AmbulanceState extends State<Ambulance> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.red),
      home: const ipset(),
    );
  }
}
