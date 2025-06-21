import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:geolocator/geolocator.dart';

class QRPage extends StatefulWidget {
  const QRPage({super.key});

  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _badgeIdController = TextEditingController();
  String _status = '';
  bool _loading = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _user = FirebaseAuth.instance.currentUser;
  }

  Future<bool> _isWithinDistance(String badgeId) async {
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final siteDoc = await FirebaseFirestore.instance
        .collection('heritageSites')
        .doc(badgeId)
        .get();
    if (!siteDoc.exists) return false;

    final gp = siteDoc['location'] as GeoPoint;
    final dist = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      gp.latitude,
      gp.longitude,
    );
    return dist <= 100;
  }

  Future<void> _simulateQRScan() async {
    final input = _badgeIdController.text.trim();
    final user = _user;
    if (input.isEmpty || user == null) {
      setState(() => _status = "Enter badge code and log in first.");
      return;
    }

    setState(() => _loading = true);
    try {
      final parts = input.split(":");
      final badgeId = parts[0];
      final partId = parts.length > 1 ? parts[1] : null;

      final badgeSnap = await FirebaseFirestore.instance
          .collection("badges")
          .doc(badgeId)
          .get();
      if (!badgeSnap.exists) {
        setState(() => _status = "Badge '$badgeId' not found.");
        return;
      }

      final within = await _isWithinDistance(badgeId);
      if (!within) {
        setState(() => _status = "Move closer to the site to unlock.");
        return;
      }

      final userBadgeRef = FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("badges")
          .doc(badgeId);
      final userBadgeSnap = await userBadgeRef.get();

      if (partId == null) {
        if (userBadgeSnap.exists) {
          setState(() => _status = "Badge '$badgeId' already unlocked.");
        } else {
          await userBadgeRef.set({
            "unlockedParts": [],
            "earnedAt": FieldValue.serverTimestamp(),
          });
          setState(() => _status = "Unlocked badge '$badgeId'!");
        }
      } else {
        if (!userBadgeSnap.exists) {
          setState(() => _status = "Unlock badge first before adding parts.");
        } else {
          final existing = List<String>.from(
            userBadgeSnap['unlockedParts'] ?? [],
          );
          if (existing.contains(partId)) {
            setState(() => _status = "Part '$partId' already unlocked.");
          } else {
            existing.add(partId);
            await userBadgeRef.update({"unlockedParts": existing});
            setState(() => _status = "Unlocked part '$partId'!");
          }
        }
      }
    } catch (e) {
      setState(() => _status = "Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _badgeIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qrData = _user != null ? "USER:${_user!.uid}" : "UNKNOWN";

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4AF37),
        title: const Text("QR Badge"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code), text: "My QR"),
            Tab(icon: Icon(Icons.input), text: "Enter Code"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(
            child: _user == null
                ? const Text("Please log in to see your QR code.")
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 250.0,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _user!.email ?? "Your Account",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Enter a badge code to simulate a QR scan:",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _badgeIdController,
                  decoration: const InputDecoration(
                    labelText: "Badge ID (e.g. MELAKA_PALACE:WELL_01)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _simulateQRScan,
                  child: _loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Submit Badge Code"),
                ),
                const SizedBox(height: 20),
                Text(
                  _status,
                  style: const TextStyle(fontSize: 16, color: Colors.teal),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
