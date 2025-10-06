import 'package:flutter/material.dart';

class HealthOverviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color statusColor;

  const HealthOverviewCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.07),
            blurRadius: 5,
            spreadRadius: 0.5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: 6), // Reduced from 12 to 6
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 22), // Reduced from 28
            const SizedBox(height: 4), // Reduced from 8
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16, // Reduced from 14.5
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4), // Reduced from 6
            Text(
              subtitle,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14, // Reduced from 12.5
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
