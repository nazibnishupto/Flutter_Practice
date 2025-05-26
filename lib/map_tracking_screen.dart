import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapTrackingScreen extends StatefulWidget {
  const MapTrackingScreen({super.key});

  @override
  State<MapTrackingScreen> createState() => _MapTrackingScreenState();
}

class _MapTrackingScreenState extends State<MapTrackingScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Marker? _currentMarker;
  List<LatLng> _routePoints = [];
  Polyline _polyline = Polyline(
    polylineId: PolylineId("route"),
    color: Colors.blue,
    width: 5,
    points: [],
  );

  Position? currentPosition;
  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  Future<void> _startTracking() async {

    _onLocationServiceAndPermissionEnabled(() async{
      Position position = await Geolocator.getCurrentPosition();
      print(position);
      currentPosition = position;
      _updateMap(position);

      // Start listening every 10 seconds
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
          intervalDuration: Duration(seconds: 10),
        ),
      ).listen((Position position) {
        _updateMap(position);
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
        _startTracking();
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

  Future<void> _updateMap(Position position) async {
    final LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    // Add to route points
    _routePoints.add(currentLatLng);
    setState(() {
      _currentMarker = Marker(
        markerId: MarkerId("currentLocation"),
        position: currentLatLng,
        infoWindow: InfoWindow(
          title: "My current location",
          snippet: "Lat: ${position.latitude}, Lng: ${position.longitude}",
        ),
      );
      _polyline = _polyline.copyWith(pointsParam: _routePoints);
    });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: currentLatLng,
      zoom: 17,
    )));
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Real-Time Location Tracker")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(23.8103, 90.4125),
          zoom: 12,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _currentMarker != null ? {_currentMarker!} : {},
        polylines: {_polyline},
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
