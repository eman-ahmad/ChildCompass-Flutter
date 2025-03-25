import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:async';
import 'dart:ui' as ui;

class ParentMapScreen extends StatefulWidget {
  @override
  _ParentMapScreenState createState() => _ParentMapScreenState();
}

class _ParentMapScreenState extends State<ParentMapScreen> with WidgetsBindingObserver {
  MapboxMap? mapboxMap;
  Timer? locationUpdateTimer;
  Point currentChildPosition = Point(coordinates: Position(-74.0060, 40.7128));
  CircleAnnotationManager? circleAnnotationManager;
  PolylineAnnotationManager? polylineAnnotationManager;
  List<Position> locationHistory = [];
  ui.Image? customMarkerImage;

  final List<Point> dummyLocations = [
    Point(coordinates: Position(-74.0060, 40.7128)),
    Point(coordinates: Position(-74.0050, 40.7130)),
    Point(coordinates: Position(-74.0040, 40.7135)),
    Point(coordinates: Position(-74.0030, 40.7140)),
    Point(coordinates: Position(-74.0020, 40.7145)),
  ];
  int currentLocationIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add this line
    _loadCustomMarkerImage();
    startLocationUpdates();
  }

  Future<void> _loadCustomMarkerImage() async {
    try {
      final ByteData data = await rootBundle.load('assets/images/child1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo fi = await codec.getNextFrame();
      setState(() {
        customMarkerImage = fi.image;
      });
    } catch (e) {
      print("Error loading marker image: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Add this line
    locationUpdateTimer?.cancel();
    circleAnnotationManager?.deleteAll(); // Add this line
    polylineAnnotationManager?.deleteAll(); // Add this line
    mapboxMap?.dispose(); // Add this line
    super.dispose();
  }



  void startLocationUpdates() {
    locationUpdateTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      updateChildLocation();
    });
  }

  void updateChildLocation() {
    setState(() {
      currentLocationIndex = (currentLocationIndex + 1) % dummyLocations.length;
      currentChildPosition = dummyLocations[currentLocationIndex];
      locationHistory.add(currentChildPosition.coordinates);

      if (mapboxMap != null) {
        _updateMarkerOnMap();
        updatePolyline();
        animateCameraToNewLocation();
      }
    });
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;

    mapboxMap.annotations.createCircleAnnotationManager().then((manager) {
      circleAnnotationManager = manager;
      _addChildLocationMarker();
    });

    mapboxMap.annotations.createPolylineAnnotationManager().then((manager) {
      polylineAnnotationManager = manager;
    });
  }

  Future<void> _addChildLocationMarker() async {
    if (customMarkerImage == null || mapboxMap == null || circleAnnotationManager == null) return;

    try {
      // Convert ui.Image to Uint8List
      final ByteData? byteData = await customMarkerImage!.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return;

      // Create circle annotation with custom styling
      circleAnnotationManager!.create(
        CircleAnnotationOptions(
          geometry: currentChildPosition,
          circleColor: Colors.blue.value,
          circleRadius: 10.0,
          circleStrokeColor: Colors.white.value,
          circleStrokeWidth: 2.0,
        ),
      );
    } catch (e) {
      print('Error adding marker: $e');
    }
  }

  Future<void> _updateMarkerOnMap() async {
    if (circleAnnotationManager == null) return;
    await circleAnnotationManager!.deleteAll();
    await _addChildLocationMarker();
  }

  Future<void> updatePolyline() async {
    if (polylineAnnotationManager == null || locationHistory.length < 2) return;

    await polylineAnnotationManager!.deleteAll();

    await polylineAnnotationManager!.create(
      PolylineAnnotationOptions(
        geometry: LineString(coordinates: locationHistory),
        lineColor: Colors.blue.value,
        lineWidth: 3.0,
      ),
    );
  }

  void animateCameraToNewLocation() {
    mapboxMap?.flyTo(
      CameraOptions(
        center: currentChildPosition,
        zoom: 15.0,
      ),
      MapAnimationOptions(duration: 1000, startDelay: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Child Live Location')),
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("mapWidget"),
            onMapCreated: _onMapCreated,
            styleUri: MapboxStyles.MAPBOX_STREETS,
            cameraOptions: CameraOptions(
              center: currentChildPosition,
              zoom: 15.0,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Child Location:\n'
                      'Lat: ${currentChildPosition.coordinates.lat.toStringAsFixed(5)}\n'
                      'Lng: ${currentChildPosition.coordinates.lng.toStringAsFixed(5)}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}