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
  bool _loading = false;

  Future<void> _simulateQRScan() async {
    final badgeId = _badgeIdController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (badgeId.isEmpty || user == null) {
      setState(() {
        _status = "Please enter a badge ID and make sure you're logged in.";
      });
      return;
    }

    setState(() => _loading = true);

    try {
      final userBadgeRef = FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Simulate QR Scan")),
      body: Padding(
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
              onPressed: _loading ? null : _simulateQRScan,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Simulate QR Scan"),
            ),
            const SizedBox(height: 24),
            Text(
              _status,
              style: const TextStyle(fontSize: 16, color: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}
