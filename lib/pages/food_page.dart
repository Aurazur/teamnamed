import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() => _currentPosition = position);
  }

  double _distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE76F51),
        foregroundColor: Colors.white,
        title: const Text("Local Food Deals"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Show your QR code to the cashier to get 5% off your meal!",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFFF3E0),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('localFood').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || _currentPosition == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final places = snapshot.data!.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final GeoPoint geoPoint = data['location'];
                final double lat = geoPoint.latitude;
                final double lng = geoPoint.longitude;
                final double distance =
                    _distanceBetween(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                      lat,
                      lng,
                    ) /
                    1000; // in KM

                if (distance > 5.0) return null;

                return {'data': data, 'distance': distance};
              })
              .whereType<Map<String, dynamic>>() // Filter out nulls
              .toList();

          return ListView.separated(
            itemCount: places.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.grey,
            ),
            itemBuilder: (context, index) {
              final item = places[index];
              final data = item['data'];
              final distance = item['distance'];

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                title: Text(data['name'] ?? 'Unnamed'),
                subtitle: Text("${distance.toStringAsFixed(2)} km away"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (_) => _MenuSheet(menu: data['menu'] ?? []),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MenuSheet extends StatelessWidget {
  final List<dynamic> menu;

  const _MenuSheet({required this.menu});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Menu",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...menu.map((item) {
            return ListTile(
              title: Text(item['name'] ?? 'Unnamed'),
              subtitle: Text(item['description'] ?? ''),
              trailing: Text(
                "RM${(item['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
