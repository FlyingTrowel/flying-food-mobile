import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:custom_info_window/custom_info_window.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  LocationData? _currentLocation;
  final Location _locationService = Location();
  final List<Marker> _markers = [];
  final CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();

  static const CameraPosition _kDefaultLocation = CameraPosition(
    target: LatLng(6.451780581110351, 100.27784842213879),
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndGetLocation();
    _loadMarkers();
    _locationService.onLocationChanged.listen((LocationData locationData) {
      setState(() {
        _currentLocation = locationData;
      });
    });
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if GPS is enabled
    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check if location permissions are granted
    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _currentLocation = null;
        });
        return;
      }
    }

    final locationData = await _locationService.getLocation();
    setState(() {
      _currentLocation = locationData;
    });
  }

  Future<void> _loadMarkers() async {
    // Mock data for marker locations and info
    List<Map<String, dynamic>> markerData = [
      {
        "location": LatLng(6.4485680435702575, 100.28012124888713),
        "operatorName": "FoodTruck 1",
        "menu": "Pizza, Burger, Coke",
        "schedule": "Monday - Friday 7:00 - 18:00"
      },
      {
        "location": LatLng(6.450091075402806, 100.28034445202745),
        "operatorName": "FoodTruck 2",
        "menu": "Tacos, Burritos, Soda",
        "schedule": "Monday - Friday 8:00 - 19:00"
      },
      {
        "location": LatLng(5.680852603799453, 100.49397257956794),
        "operatorName": "FoodTruck 3",
        "menu": "Sushi, Ramen, Tea",
        "schedule": "Monday - Friday 9:00 - 20:00"
      },
    ];

    for (var marker in markerData) {
      _markers.add(
        Marker(
          markerId: MarkerId(marker["location"].toString()),
          position: marker["location"],
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          onTap: () {
            _customInfoWindowController.addInfoWindow!(
              _buildCustomInfoWindowContent(marker["operatorName"], marker["menu"], marker["schedule"]),
              marker["location"],
            );
          },
        ),
      );
    }

    setState(() {});
  }

  Widget _buildCustomInfoWindowContent(String operatorName, String menu, String schedule) {
    return Container(
      width: 200,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            operatorName,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            menu,
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 5),
          Text(
            schedule,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _moveToUserLocation() async {
    if (_currentLocation != null) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          zoom: 15,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.terrain,
            initialCameraPosition: _currentLocation != null
                ? CameraPosition(
              target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
              zoom: 15,
            )
                : _kDefaultLocation,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _customInfoWindowController.googleMapController = controller;
            },
            markers: Set<Marker>.of(_markers),
            onTap: (position) {
              _customInfoWindowController.hideInfoWindow!();
            },
            onCameraMove: (position) {
              _customInfoWindowController.onCameraMove!();
            },
          ),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 100,
            width: 250,
            offset: 50,
          ),
          Positioned(
            right: 16.0,
            bottom: 100.0,
            child: FloatingActionButton.extended(
              onPressed: _moveToUserLocation,
              label: const Text('Move to my location'),
              icon: const Icon(Icons.my_location),
              backgroundColor: Colors.orangeAccent,
            ),
          ),
        ],
      ),
    );
  }
}
