import 'package:flutter/material.dart';

import 'Pages/ipset.dart';


void main() {
  runApp(const KSRTC());
}

class KSRTC extends StatefulWidget {
  const KSRTC({super.key});

  @override
  State<KSRTC> createState() => _KSRTCState();
}

class _KSRTCState extends State<KSRTC> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.red),
      home: const ipset(),
    );
  }
}