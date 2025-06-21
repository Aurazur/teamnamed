import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nearbySites = [
      {
        'name': 'Melaka Sultanate Palace',
        'type': 'Historical Museum',
        'distance': '2.3 km',
        'location': 'Melaka City',
        'description':
            'Replica of the 15th-century palace of the Melaka Sultanate.',
      },
      {
        'name': 'Kampung Baru',
        'type': 'Cultural Village',
        'distance': '5.0 km',
        'location': 'Kuala Lumpur',
        'description': 'Traditional Malay village in the heart of the city.',
      },
      {
        'name': 'Istana Negara',
        'type': 'Royal Palace',
        'distance': '7.8 km',
        'location': 'Kuala Lumpur',
        'description': 'Official residence of the Malaysian King.',
      },
    ];

    final badges = [
      {
        'name': 'Melaka Heritage Explorer',
        'tier': 'Silver',
        'completion': '29/40',
      },
      {'name': 'Kampung Tradisi', 'tier': 'Bronze', 'completion': '2/16'},
      {'name': 'Istana Visitor', 'tier': 'Gold', 'completion': '17/17'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final halfHeight = constraints.maxHeight / 2;
          return Column(
            children: [
              SizedBox(
                height: halfHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nearby Sites',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE76F51),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AllSitesPage(sites: nearbySites),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: nearbySites.length,
                          itemBuilder: (context, index) {
                            final site = nearbySites[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    site['name']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    site['type']!,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    "📍 ${site['distance']} away",
                                    style: TextStyle(color: Colors.teal[800]),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: halfHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Badges',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE76F51),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AllBadgesPage(badges: badges),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: badges.length,
                          itemBuilder: (context, index) {
                            final badge = badges[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: badge['tier'] == 'Gold'
                                      ? const Color(0xFFFFD700)
                                      : badge['tier'] == 'Silver'
                                      ? const Color(0xFFC0C0C0)
                                      : const Color(0xFFCD7F32),
                                  width: 2,
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    badge['name']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text("Tier: ${badge['tier']}"),
                                  Text(
                                    "✔ ${badge['completion']} complete",
                                    style: TextStyle(color: Colors.green[700]),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// display all sites
class AllSitesPage extends StatelessWidget {
  final List<Map<String, String>> sites;
  const AllSitesPage({super.key, required this.sites});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B4F27),
        title: const Text(
          "All Nearby Sites",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sites.length,
        itemBuilder: (context, index) {
          final site = sites[index];
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                site['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${site['type']} • ${site['distance']}"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(site['name']!),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Type: ${site['type']}"),
                        Text("Location: ${site['location']}"),
                        Text("Distance: ${site['distance']}"),
                        const SizedBox(height: 8),
                        Text(site['description']!),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Close"),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// display all badges
class AllBadgesPage extends StatelessWidget {
  final List<Map<String, String>> badges;
  const AllBadgesPage({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B4F27),
        title: const Text("All Badges", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          final borderColor = badge['tier'] == 'Gold'
              ? const Color(0xFFFFD700)
              : badge['tier'] == 'Silver'
              ? const Color(0xFFC0C0C0)
              : const Color(0xFFCD7F32);

          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                badge['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Tier: ${badge['tier']}"),
              trailing: const Icon(Icons.star),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(badge['name']!),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Tier: ${badge['tier']}"),
                        Text("Completion: ${badge['completion']}"),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Close"),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
