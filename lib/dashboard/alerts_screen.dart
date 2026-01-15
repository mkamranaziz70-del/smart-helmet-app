// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AlertsHistoryScreen extends StatelessWidget {
  AlertsHistoryScreen({super.key});

  final DatabaseReference _alertsRef =
      FirebaseDatabase.instance.ref('helmet/alerts_history');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EEE4),
      appBar: AppBar(
        title: const Text(
          "Alerts Timeline",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _alertsRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null) {
            return _emptyState();
          }

          final Map<dynamic, dynamic> raw =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          final alerts = raw.values
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
            ..sort(
              (a, b) =>
                  (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0),
            );

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];

              final String type = alert['type'] ?? 'unknown';
              final bool isAccident = type == 'accident';

              final int timestamp = alert['timestamp'] ?? 0;
              final String time = timestamp == 0
                  ? "N/A"
                  : DateFormat('dd MMM yyyy • HH:mm:ss').format(
                      DateTime.fromMillisecondsSinceEpoch(
                        timestamp,
                        isUtc: true,
                      ).toLocal(),
                    );

              final double? lat = alert['latitude'] != null
                  ? (alert['latitude'] as num).toDouble()
                  : null;

              final double? lng = alert['longitude'] != null
                  ? (alert['longitude'] as num).toDouble()
                  : null;

              final double? jerk = alert['jerk'] != null
                  ? (alert['jerk'] as num).toDouble()
                  : null;

              final double? netAcc = alert['net_acc'] != null
                  ? (alert['net_acc'] as num).toDouble()
                  : null;

              return _alertCard(
                isAccident: isAccident,
                title: isAccident ? "ACCIDENT" : "SMOKE",
                time: time,
                lat: lat,
                lng: lng,
                jerk: jerk,
                netAcc: netAcc,
              );
            },
          );
        },
      ),
    );
  }

  /* ================= ALERT CARD ================= */

  Widget _alertCard({
    required bool isAccident,
    required String title,
    required String time,
    double? lat,
    double? lng,
    double? jerk,
    double? netAcc,
  }) {
    final Color accent =
        isAccident ? Colors.redAccent : Colors.orangeAccent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: accent.withOpacity(0.18),
                      child: Icon(
                        isAccident
                            ? Icons.local_hospital_rounded
                            : Icons.warning_amber_rounded,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// IMPACT
                if (jerk != null && netAcc != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _metric("Jerk", jerk.toStringAsFixed(3)),
                      _metric("Net Acc", netAcc.toStringAsFixed(3)),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                /// LOCATION
                if (lat != null && lng != null) ...[
                  InkWell(
                    onTap: () async {
                      final uri = Uri.parse(
                        "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
                      );
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.location_on_rounded,
                            color: Colors.blue),
                        SizedBox(width: 6),
                        Text(
                          "Open location",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                /// TIME
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_rounded,
              size: 72, color: Colors.black38),
          SizedBox(height: 16),
          Text(
            "No alerts recorded yet",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
