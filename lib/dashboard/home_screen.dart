// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'live_data_screen.dart';
import 'alerts_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final DatabaseReference _helmetRef =
      FirebaseDatabase.instance.ref('helmet/live');

  static const int SMOKE_THRESHOLD = 700;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF4EA),

      /* ================= APP BAR ================= */
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFDFF2B2),
        foregroundColor: Colors.black,
        title: Row(
          children: [
            Image.asset(
              'assets/images/helmet_logo.png',
              height: 48,
            ),
            const SizedBox(width: 10),
            const Text(
              "Smart Helmet",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),

      /* ================= BODY ================= */
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _homeTab(),
          LiveDataScreen(),
          AlertsHistoryScreen(),
          MapScreen(),
          ProfileScreen(),
        ],
      ),

      /* ================= BOTTOM NAV ================= */
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF9BC53D),
        unselectedItemColor: Colors.black54,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: "Live",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_rounded),
            label: "Alerts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            label: "Map",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  /* =========================================================
   * HOME TAB (DASHBOARD)
   * =======================================================*/
  Widget _homeTab() {
    return StreamBuilder<DatabaseEvent>(
      stream: _helmetRef.onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final Map<String, dynamic> data =
            Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

        final int gas = data['gas'] ?? 0;
        final bool smoke = gas > SMOKE_THRESHOLD;

        final bool accident = data['accident'] ?? false;
        final bool gpsFix = data['gps_fix'] ?? false;
        final bool simReady = data['sim_ready'] ?? false;

        final double jerk =
            (data['jerk'] ?? 0).toDouble();

        final double netAcc =
            (data['net_acc'] ?? 0).toDouble();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔥 HERO STATUS CARD
              _heroStatusCard(accident),

              const SizedBox(height: 22),

              /// QUICK STATS GRID
              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      title: "Smoke",
                      value: smoke ? "DETECTED" : "SAFE",
                      color: smoke ? Colors.redAccent : Colors.green,
                      icon: Icons.cloud_rounded,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _infoCard(
                      title: "GPS",
                      value: gpsFix ? "FIXED" : "SEARCHING",
                      color: gpsFix ? Colors.green : Colors.orange,
                      icon: Icons.gps_fixed_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      title: "SIM",
                      value: simReady ? "READY" : "NOT READY",
                      color: simReady ? Colors.green : Colors.redAccent,
                      icon: Icons.sim_card_rounded,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _infoCard(
                      title: "Impact",
                      value:
                          "${jerk.toStringAsFixed(2)} g\nNet ${netAcc.toStringAsFixed(2)}",
                      color: jerk > 1.2
                          ? Colors.redAccent
                          : Colors.blueGrey,
                      icon: Icons.speed_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              /// SENSOR DETAIL CARD
              _glassDetailCard(
                title: "Smoke Sensor (ADC)",
                value: gas.toString(),
                subtitle: "Raw sensor value",
                icon: Icons.sensors_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  /* =========================================================
   * HERO CARD
   * =======================================================*/
  Widget _heroStatusCard(bool accident) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: (accident
                        ? Colors.redAccent
                        : Colors.green)
                    .withOpacity(0.15),
                child: Icon(
                  accident
                      ? Icons.warning_rounded
                      : Icons.verified_user_rounded,
                  size: 34,
                  color: accident
                      ? Colors.redAccent
                      : Colors.green,
                ),
              ),
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Helmet Status",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    accident ? "ACCIDENT DETECTED" : "ALL SYSTEMS NORMAL",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: accident
                          ? Colors.redAccent
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* =========================================================
   * INFO CARD
   * =======================================================*/
  Widget _infoCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /* =========================================================
   * GLASS DETAIL CARD
   * =======================================================*/
  Widget _glassDetailCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.black87),
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
