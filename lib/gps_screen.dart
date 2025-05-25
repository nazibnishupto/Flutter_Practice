import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GpsScreen extends StatefulWidget {
  const GpsScreen({super.key});

  @override
  State<GpsScreen> createState() => _GpsScreenState();
}

class _GpsScreenState extends State<GpsScreen> {
  Position? currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  Future<void> _getCurrentLocation() async {

    _onLocationServiceAndPermissionEnabled(() async{
      Position position = await Geolocator.getCurrentPosition();
      print(position);
      currentPosition = position;
      setState(() {});
    });
  }

  Future<void> _listenCurrentLocation() async {

    _onLocationServiceAndPermissionEnabled(() async{
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Lower it to test more easily
      );
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        setState(() {
          currentPosition = position;
        });
        print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
      });
    });
  }


  Future<void> _onLocationServiceAndPermissionEnabled(VoidCallback onSuccess) async{
    bool _isPermissionEnabled = await _isLocationPermissionEnabled();
    if (_isPermissionEnabled) {
      bool _isGpsServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (_isGpsServiceEnabled) {
        onSuccess();
      } else {
        Geolocator.openLocationSettings();
      }
    } else {
      bool _isPermissionGranted = await _requestPermission();
      if (_isPermissionGranted) {
        _getCurrentLocation();
      }
    }
  }


  Future<bool> _isLocationPermissionEnabled() async {
    LocationPermission locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.always ||
        locationPermission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _requestPermission() async {
    LocationPermission locationPermission =
    await Geolocator.requestPermission();
    if (locationPermission == LocationPermission.always ||
        locationPermission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentPosition != null
                  ? "My Current Location: ${currentPosition!.latitude}, ${currentPosition!.longitude}"
                  : "My Current Location: Not available",
            ),
            TextButton(
              onPressed: () {
                _getCurrentLocation();
              },
              child: Text("Location"),
            ),
            TextButton(
              onPressed: () {
                _listenCurrentLocation();
              },
              child: Text("Listen"),
            ),
          ],
        ),
      ),
    );
  }
}