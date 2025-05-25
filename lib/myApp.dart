import 'package:flutter/material.dart';

import 'gps_screen.dart';

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GpsScreen(),
    );
  }
}