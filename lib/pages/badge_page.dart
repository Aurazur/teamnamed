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
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text("My Badges"),
        backgroundColor: const Color(0xFFD4AF37),
      ),
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
              final isOwned = badge['isOwned'] as bool;
              final progress = badge['required'] > 0
                  ? (badge['unlocked'] / badge['required']).clamp(0.0, 1.0)
                  : 0.0;

              final progressColor = progress == 0 ? Colors.red : Colors.green;

              return Opacity(
                opacity: isOwned ? 1.0 : 0.4,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(badge['name']),
                      subtitle: Text(
                        isOwned
                            ? "${badge['tier']} • ${badge['unlocked']} / ${badge['required']} parts unlocked"
                            : "Not earned",
                      ),
                      trailing: isOwned
                          ? Icon(
                              Icons.emoji_events,
                              color: _getTierColor(badge['tier']),
                            )
                          : const Icon(Icons.lock_outline, color: Colors.grey),
                    ),
                    if (isOwned)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: LinearProgressIndicator(
                          value: progress,
                          color: progressColor,
                          backgroundColor: Colors.grey[300],
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    const Divider(),
                  ],
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
        'isOwned': userDoc.exists,
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
    if (unlocked >= 0) return "Bronze";
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
        return Colors.grey;
    }
  }
}
