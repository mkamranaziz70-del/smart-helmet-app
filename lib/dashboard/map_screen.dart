// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatelessWidget {
  MapScreen({super.key});

  final DatabaseReference _helmetRef =
      FirebaseDatabase.instance.ref('helmet/live');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EEE4),
      appBar: AppBar(
        title: const Text(
          "Live Location",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white.withOpacity(0.9),
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _helmetRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return _waitingState();
          }

          final data =
              Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

          final bool gpsFix = data['gps_fix'] ?? false;

          if (!gpsFix ||
              data['latitude'] == null ||
              data['longitude'] == null) {
            return _waitingState();
          }

          final double lat = (data['latitude'] as num).toDouble();
          final double lng = (data['longitude'] as num).toDouble();

          final Uri mapUri = Uri.parse(
            "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
          );

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// ICON
                        CircleAvatar(
                          radius: 36,
                          backgroundColor:
                              Colors.redAccent.withOpacity(0.15),
                          child: const Icon(
                            Icons.location_on_rounded,
                            size: 40,
                            color: Colors.redAccent,
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// TITLE
                        const Text(
                          "Helmet Location Active",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        /// STATUS
                        const Text(
                          "GPS fix acquired • Live tracking",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// COORDINATES CARD
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _coordItem("Latitude", lat.toStringAsFixed(6)),
                              _coordItem("Longitude", lng.toStringAsFixed(6)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        /// MAP BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.map_rounded),
                            label: const Text(
                              "Open in Google Maps",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () async {
                              await launchUrl(
                                mapUri,
                                mode: LaunchMode.externalApplication,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /* =========================================================
   * COORD ITEM
   * =======================================================*/
  Widget _coordItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /* =========================================================
   * WAITING STATE
   * =======================================================*/
  Widget _waitingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.gps_not_fixed_rounded,
            size: 72,
            color: Colors.black38,
          ),
          SizedBox(height: 14),
          Text(
            "Waiting for GPS signal",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Move to open area for better reception",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}
