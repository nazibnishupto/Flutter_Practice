import 'package:flutter/material.dart';
import 'package:flutter_program/map_screen.dart';
import 'package:flutter_program/map_tracking_screen.dart';


class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapTrackingScreen(),
    );
  }
}