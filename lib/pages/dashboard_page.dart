import 'package:flutter/material.dart';
import 'qr_page.dart';
import 'badge_page.dart';
import 'nearby_page.dart';
import 'food_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'label': 'Nearby Sites',
        'icon': Icons.place,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NearbyPage()),
          );
        },
      },
      {
        'label': 'Badges',
        'icon': Icons.emoji_events,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BadgePage()),
          );
        },
      },
      {
        'label': 'Local Food Deals',
        'icon': Icons.restaurant,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FoodPage()),
          );
        },
      },
      {'label': 'Audio Guides', 'icon': Icons.headphones, 'onTap': () {}},
      {'label': 'Multilingual Info', 'icon': Icons.language, 'onTap': () {}},
      {
        'label': 'Scan QR',
        'icon': Icons.qr_code_scanner,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QRPage()),
          );
        },
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: actions.map((action) {
            return GestureDetector(
              onTap: action['onTap'] as void Function(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      action['icon'] as IconData,
                      size: 40,
                      color: const Color(0xFFE76F51),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      action['label'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B4F27),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
