import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final userId = FirebaseAuth.instance.currentUser!.uid;

Future<void> unlockSiteBadge(String badgeId) async {
  final badgeRef = FirebaseFirestore.instance
      .collection('user_badges')
      .doc('$userId-$badgeId');
  final doc = await badgeRef.get();

  if (!doc.exists) {
    await badgeRef.set({
      'userId': userId,
      'badgeId': badgeId,
      'partsUnlocked': [],
      'unlocked': true,
      'tier': 'Bronze',
    });
  }
}

Future<void> unlockBadgePart(String badgeId, String partId) async {
  final badgeDoc = await FirebaseFirestore.instance
      .collection('user_badges')
      .doc('$userId-$badgeId')
      .get();
  if (!badgeDoc.exists) return; // Badge must be unlocked first

  final data = badgeDoc.data()!;
  final partsUnlocked = List<String>.from(data['partsUnlocked']);
  if (partsUnlocked.contains(partId)) return;

  partsUnlocked.add(partId);
  String tier = 'Bronze';
  if (partsUnlocked.length >= 3)
    tier = 'Gold';
  else if (partsUnlocked.length >= 2)
    tier = 'Silver';

  await badgeDoc.reference.update({
    'partsUnlocked': partsUnlocked,
    'tier': tier,
  });
}
