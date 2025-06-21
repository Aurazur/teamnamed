import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

  Future<void> _simulateQRScan() async {
    final badgeId = _badgeIdController.text.trim();

    if (badgeId.isEmpty || _user == null) {
      setState(() {
        _status = "Please enter a badge ID and make sure you're logged in.";
      });
      return;
    }

    setState(() => _loading = true);

    try {
      final userBadgeRef = FirebaseFirestore.instance
          .collection("users")
          .doc(_user!.uid)
          .collection("badges")
          .doc(badgeId);

      final badgeDoc = await userBadgeRef.get();

      if (badgeDoc.exists) {
        setState(() {
          _status = "You already have this badge!";
        });
      } else {
        final badgeMeta = await FirebaseFirestore.instance
            .collection("badges")
            .doc(badgeId)
            .get();

        if (!badgeMeta.exists) {
          setState(() {
            _status = "Badge ID not found in the system.";
          });
        } else {
          await userBadgeRef.set({
            "unlockedParts": [],
            "earnedAt": FieldValue.serverTimestamp(),
          });
          setState(() {
            _status = "Badge '$badgeId' successfully added!";
          });
        }
      }
    } catch (e) {
      setState(() {
        _status = "An error occurred: $e";
      });
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
      appBar: AppBar(
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
          // TAB 1: My QR Code
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

          // TAB 2: Manual badge code entry
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
