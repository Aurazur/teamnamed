import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BadgePage extends StatelessWidget {
  const BadgePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    final badgeRef = FirebaseFirestore.instance.collection('badges');
    final userBadgeRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('badges');

    return Scaffold(
      appBar: AppBar(title: const Text("My Badges")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadBadgesWithUserProgress(badgeRef, userBadgeRef),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text('Error loading badges'));
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final badges = snapshot.data!;

          return ListView.builder(
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];

              return ListTile(
                title: Text(badge['name']),
                subtitle: Text(
                  "${badge['tier']} • ${badge['unlocked']} / ${badge['required']} parts unlocked",
                ),
                trailing: Icon(
                  Icons.emoji_events,
                  color: _getTierColor(badge['tier']),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadBadgesWithUserProgress(
    CollectionReference badgeRef,
    CollectionReference userBadgeRef,
  ) async {
    final badgeSnapshots = await badgeRef.get();
    final List<Map<String, dynamic>> owned = [];
    final List<Map<String, dynamic>> notOwned = [];

    for (var doc in badgeSnapshots.docs) {
      final badgeId = doc.id;
      final badgeData = doc.data() as Map<String, dynamic>;
      final name = badgeData['name'] ?? 'Unnamed Badge';
      final parts = List<String>.from(badgeData['parts'] ?? []);
      final partsRequired = badgeData['partsRequired'] ?? parts.length;

      final userDoc = await userBadgeRef.doc(badgeId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      final unlockedParts = userData != null
          ? List<String>.from(userData['unlockedParts'] ?? [])
          : <String>[];

      final unlockedCount = unlockedParts.length;
      final tier = _getCalculatedTier(unlockedCount, partsRequired);

      final badgeEntry = {
        'id': badgeId,
        'name': name,
        'unlocked': unlockedCount,
        'required': partsRequired,
        'tier': tier,
      };

      if (userDoc.exists) {
        owned.add(badgeEntry);
      } else {
        notOwned.add(badgeEntry);
      }
    }

    return [...owned, ...notOwned];
  }

  String _getCalculatedTier(int unlocked, int required) {
    if (unlocked >= required) return "Gold";
    if (unlocked >= (required / 2).ceil()) return "Silver";
    if (unlocked > 0) return "Bronze";
    return "Not Owned";
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case "Gold":
        return Colors.amber;
      case "Silver":
        return Colors.grey;
      case "Bronze":
        return Colors.brown;
      default:
        return Colors.black45;
    }
  }
}
