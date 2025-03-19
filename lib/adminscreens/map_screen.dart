import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../widgets/app_drawer.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Set<Circle> _geofenceCircles = {};
  
  MapType _currentMapType = MapType.normal;
  bool _trafficEnabled = false;
  String _selectedClass = 'All';
  String _selectedRoute = 'All';
  String _selectedBus = 'All';
  
  // Initial camera position (Dhaka)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(23.8103, 90.4125),
    zoom: 14.0,
  );

  static const LatLng _center = LatLng(23.8103, 90.4125); // Dhaka

  final Set<Marker> _markers2 = {
    const Marker(
      markerId: MarkerId('school'),
      position: LatLng(23.8103, 90.4125),
      infoWindow: InfoWindow(
        title: 'School',
        snippet: 'Main Campus',
      ),
    ),
  };

  final Set<Circle> _circles = {
    Circle(
      circleId: const CircleId('school_zone'),
      center: const LatLng(23.8103, 90.4125),
      radius: 500, // 500 meters
      fillColor: Colors.blue.withOpacity(0.2),
      strokeColor: Colors.blue,
      strokeWidth: 2,
    ),
  };

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadBusLocations();
    _setupGeofence();
    _startLocationUpdates();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
      _addSchoolMarker();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _addSchoolMarker() {
    _markers.add(
      const Marker(
        markerId: MarkerId('school'),
        position: LatLng(23.8103, 90.4125), // School location
        infoWindow: InfoWindow(title: 'School'),
      ),
    );
    setState(() {});
  }

  void _setupGeofence() {
    _geofenceCircles.add(
      Circle(
        circleId: const CircleId('school_geofence'),
        center: const LatLng(23.8103, 90.4125),
        radius: 500, // 500 meters
        fillColor: Colors.blue.withOpacity(0.1),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ),
    );
    setState(() {});
  }

  void _startLocationUpdates() {
    // Simulate bus movement (In real app, this would be real-time data)
    Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateBusLocations();
    });
  }

  void _updateBusLocations() {
    // Simulate bus movement
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value.startsWith('bus'));
      _addBusMarker(const LatLng(23.8150, 90.4160), 'Bus 1');
      _addBusMarker(const LatLng(23.8080, 90.4100), 'Bus 2');
    });
  }

  void _addBusMarker(LatLng position, String busId) {
    _markers.add(
      Marker(
        markerId: MarkerId(busId),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: InfoWindow(
          title: busId,
          snippet: 'Speed: 40 km/h',
        ),
      ),
    );
  }

  void _loadBusLocations() {
    // Add sample bus routes (In real app, this would be from API)
    _addBusMarker(const LatLng(23.8150, 90.4160), 'Bus 1');
    _addBusMarker(const LatLng(23.8080, 90.4100), 'Bus 2');
    
    // Add route polyline
    _addRoute();
  }

  void _addRoute() {
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('bus_route_1'),
        color: Colors.blue,
        width: 3,
        points: const [
          LatLng(23.8103, 90.4125), // School
          LatLng(23.8150, 90.4160), // Bus 1
          LatLng(23.8080, 90.4100), // Bus 2
        ],
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Track Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: _showMapTypeMenu,
          ),
          IconButton(
            icon: Icon(
              Icons.traffic,
              color: _trafficEnabled ? Colors.green : null,
            ),
            onPressed: _toggleTraffic,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            polylines: _polylines,
            circles: _geofenceCircles,
            mapType: _currentMapType,
            trafficEnabled: _trafficEnabled,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            compassEnabled: true,
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.directions_bus),
                      ),
                      title: const Text('Bus #123'),
                      subtitle: const Text('On Route - ETA: 10 mins'),
                      trailing: IconButton(
                        icon: const Icon(Icons.phone),
                        onPressed: () {
                          // Call bus driver
                        },
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildEmergencyButton(
                          'School',
                          Icons.school,
                          Colors.blue,
                          () {},
                        ),
                        _buildEmergencyButton(
                          'Police',
                          Icons.local_police,
                          Colors.red,
                          () {},
                        ),
                        _buildEmergencyButton(
                          'Hospital',
                          Icons.local_hospital,
                          Colors.green,
                          () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }

  void _toggleTraffic() {
    setState(() {
      _trafficEnabled = !_trafficEnabled;
    });
  }

  void _showMapTypeMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Normal'),
            onTap: () {
              setState(() => _currentMapType = MapType.normal);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.satellite),
            title: const Text('Satellite'),
            onTap: () {
              setState(() => _currentMapType = MapType.satellite);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.terrain),
            title: const Text('Terrain'),
            onTap: () {
              setState(() => _currentMapType = MapType.terrain);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Class'),
              trailing: DropdownButton<String>(
                value: _selectedClass,
                items: ['All', 'Class 1', 'Class 2', 'Class 3']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedClass = value!);
                  _filterMarkers();
                },
              ),
            ),
            ListTile(
              title: const Text('Route'),
              trailing: DropdownButton<String>(
                value: _selectedRoute,
                items: ['All', 'Route 1', 'Route 2', 'Route 3']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedRoute = value!);
                  _filterMarkers();
                },
              ),
            ),
            ListTile(
              title: const Text('Bus'),
              trailing: DropdownButton<String>(
                value: _selectedBus,
                items: ['All', 'Bus 1', 'Bus 2', 'Bus 3']
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedBus = value!);
                  _filterMarkers();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _filterMarkers() {
    // Implement marker filtering based on selected filters
    setState(() {
      // Reset and reload markers based on filters
      _loadBusLocations();
    });
  }
}
