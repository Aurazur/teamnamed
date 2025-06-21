import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _heritageSites = [];

  @override
  void initState() {
    super.initState();
    _getLocationPermissionAndPosition();
    _fetchHeritageSites();
  }

  Future<void> _getLocationPermissionAndPosition() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
    }
  }

  Future<void> _fetchHeritageSites() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('heritageSites')
        .get();
    final sites = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        "id": doc.id,
        "name": data["name"],
        "description": data["description"],
        "location": LatLng(
          (data["location"] as GeoPoint).latitude,
          (data["location"] as GeoPoint).longitude,
        ),
      };
    }).toList();

    setState(() {
      _heritageSites = sites;
    });
  }

  Set<Marker> _buildHeritageMarkers() {
    return _heritageSites.map((site) {
      return Marker(
        markerId: MarkerId(site['id']),
        position: site['location'],
        infoWindow: InfoWindow(
          title: site['name'],
          snippet: site['description'],
        ),
      );
    }).toSet();
  }

  void _searchSite() {
    final query = _searchController.text.toLowerCase().trim();
    final site = _heritageSites.firstWhere(
      (s) => s['name'].toLowerCase().contains(query),
      orElse: () => {},
    );

    if (site.isNotEmpty && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(site['location'], 17),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Site not found")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search heritage site...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _searchSite,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation!,
                      zoom: 15,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    markers: _buildHeritageMarkers(),
                  ),
                ),
              ],
            ),
    );
  }
}
