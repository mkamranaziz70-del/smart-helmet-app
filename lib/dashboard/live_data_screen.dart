// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveDataScreen extends StatelessWidget {
  LiveDataScreen({super.key});

  final DatabaseReference _helmetRef =
      FirebaseDatabase.instance.ref('helmet/live');

  static const int SMOKE_THRESHOLD = 700;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EEE4),
      appBar: AppBar(
        title: const Text(
          "Live Helmet Analytics",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _helmetRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final Map<String, dynamic> data =
              Map<String, dynamic>.from(
                  snapshot.data!.snapshot.value as Map);

          /* ================= FIREBASE VALUES ================= */

          final int gas = data['gas'] ?? 0;
          final bool smokeDetected = gas > SMOKE_THRESHOLD;

          final bool accident = data['accident'] ?? false;
          final bool simReady = data['sim_ready'] ?? false;

          final double jerk = (data['jerk'] ?? 0).toDouble();
          final double netAcc = (data['net_acc'] ?? 0).toDouble();

          final double ax = (data['ax'] ?? 0).toDouble();
          final double ay = (data['ay'] ?? 0).toDouble();
          final double az = (data['az'] ?? 0).toDouble();

          final bool gpsFix = data['gps_fix'] ?? false;

          final double? lat = data['latitude'] != null
              ? (data['latitude'] as num).toDouble()
              : null;

          final double? lng = data['longitude'] != null
              ? (data['longitude'] as num).toDouble()
              : null;

          final int timestamp = data['timestamp'] ?? 0;
          final String lastUpdate = timestamp == 0
              ? "N/A"
              : DateFormat('dd MMM yyyy • HH:mm:ss').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    timestamp,
                    isUtc: true,
                  ).toLocal(),
                );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /* ================= SYSTEM STATUS ================= */
                _glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("System Status"),
                      _statusRow(
                        "Smoke",
                        smokeDetected ? "DETECTED" : "Normal",
                        smokeDetected ? Colors.red : Colors.green,
                      ),
                      _statusRow(
                        "Accident",
                        accident ? "YES" : "NO",
                        accident ? Colors.red : Colors.green,
                      ),
                      _statusRow(
                        "GPS",
                        gpsFix ? "LOCKED" : "SEARCHING",
                        gpsFix ? Colors.green : Colors.orange,
                      ),
                      _statusRow(
                        "SIM",
                        simReady ? "READY" : "NOT READY",
                        simReady ? Colors.green : Colors.orange,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /* ================= SMOKE SENSOR ================= */
                _glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("Smoke Sensor"),
                      Text("ADC Value", style: _labelStyle),
                      const SizedBox(height: 6),
                      Text(
                        gas.toString(),
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color:
                              smokeDetected ? Colors.red : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        smokeDetected
                            ? "⚠ Smoke Detected"
                            : "Air Quality Normal",
                        style: TextStyle(
                          fontSize: 14,
                          color: smokeDetected
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /* ================= MOTION ================= */
                _glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("Motion Analytics"),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          _metric(
                              "Jerk (g)",
                              jerk.toStringAsFixed(4)),
                          _metric(
                              "Net Acc (g)",
                              netAcc.toStringAsFixed(4)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                          children: [
                            _axis("X", ax),
                            _axis("Y", ay),
                            _axis("Z", az),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /* ================= GPS ================= */
                _glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("GPS Location"),
                      Text(
                        gpsFix && lat != null
                            ? "Latitude: ${lat.toStringAsFixed(6)}"
                            : "Latitude: --",
                        style: _valueStyle,
                      ),
                      Text(
                        gpsFix && lng != null
                            ? "Longitude: ${lng.toStringAsFixed(6)}"
                            : "Longitude: --",
                        style: _valueStyle,
                      ),
                      if (gpsFix && lat != null && lng != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.map),
                            label:
                                const Text("Open in Google Maps"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(
                                      vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () async {
                              final uri = Uri.parse(
                                "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
                              );
                              await launchUrl(
                                uri,
                                mode:
                                    LaunchMode.externalApplication,
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Last update: $lastUpdate",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /* ================= UI HELPERS ================= */

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _statusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: _labelStyle),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _axis(String axis, double value) {
    return Column(
      children: [
        Text(axis,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(2),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static const TextStyle _labelStyle =
      TextStyle(fontSize: 13, color: Colors.black54);

  static const TextStyle _valueStyle =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w500);
}
