import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QRPage extends StatefulWidget {
  const QRPage({super.key});

  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  final TextEditingController _badgeIdController = TextEditingController();
  String _status = '';

  Future<void> _simulateQRScan() async {
    final badgeId = _badgeIdController.text.trim();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (badgeId.isEmpty || userId == null) {
      setState(() {
        _status = "Invalid badge ID or user not logged in.";
      });
      return;
    }

    final userBadgeRef = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
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
        return;
      }

      await userBadgeRef.set({
        "unlockedParts": [],
        "earnedAt": FieldValue.serverTimestamp(),
      });

      setState(() {
        _status = "Badge '$badgeId' successfully added to your profile!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Simulate QR Badge Unlock"),
          const SizedBox(height: 16),
          TextField(
            controller: _badgeIdController,
            decoration: const InputDecoration(
              labelText: "Enter Badge ID (e.g. TAYLORS-COLLEGE)",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _simulateQRScan,
            child: const Text("Simulate QR Scan"),
          ),
          const SizedBox(height: 24),
          Text(
            _status,
            style: const TextStyle(fontSize: 16, color: Colors.teal),
          ),
        ],
      ),
    );
  }
}
