import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  List<Map<String, dynamic>> _nearbySites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchNearbySites();
  }

  Future<void> _fetchNearbySites() async {
    var permission = await Permission.location.request();
    if (!permission.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final snapshot = await FirebaseFirestore.instance
        .collection('heritageSites')
        .get();

    final List<Map<String, dynamic>> loadedSites = snapshot.docs.map((doc) {
      final data = doc.data();
      final GeoPoint geoPoint = data['location'];
      final lat = geoPoint.latitude;
      final lng = geoPoint.longitude;

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        lat,
        lng,
      );

      return {
        'name': data['name'],
        'description': data['description'],
        'distance': distance,
      };
    }).toList();

    loadedSites.sort((a, b) => a['distance'].compareTo(b['distance']));

    setState(() {
      _nearbySites = loadedSites;
      _loading = false;
    });
  }

  String formatDistance(double meters) {
    return meters < 1000
        ? "${meters.toStringAsFixed(0)} m"
        : "${(meters / 1000).toStringAsFixed(2)} km";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text('Nearby Heritage Sites'),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _nearbySites.length,
              itemBuilder: (context, index) {
                final site = _nearbySites[index];
                return ListTile(
                  title: Text(site['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        site['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatDistance(site['distance']),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  leading: const Icon(Icons.location_on, color: Colors.teal),
                );
              },
            ),
    );
  }
}
