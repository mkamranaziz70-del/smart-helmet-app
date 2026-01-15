// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text(
          "User not logged in",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _profileHeader(user),
            const SizedBox(height: 30),
            _infoCard(
              title: "Email",
              value: user.email ?? "N/A",
              icon: Icons.email_outlined,
            ),
            _infoCard(
              title: "Email Status",
              value: user.emailVerified ? "Verified" : "Not Verified",
              icon: user.emailVerified
                  ? Icons.verified
                  : Icons.warning_amber_outlined,
              valueColor:
                  user.emailVerified ? Colors.green : Colors.red,
            ),
            _infoCard(
              title: "Account Created",
              value: user.metadata.creationTime != null
                  ? user.metadata.creationTime!
                      .toLocal()
                      .toString()
                      .split('.')
                      .first
                  : "N/A",
              icon: Icons.calendar_today_outlined,
            ),
            const SizedBox(height: 40),
            _logoutButton(context),
          ],
        ),
      ),
    );
  }

  /* ================= PROFILE HEADER ================= */

  Widget _profileHeader(User user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: const Color(0xFFB6E300),
          child: Text(
            (user.displayName != null && user.displayName!.isNotEmpty)
                ? user.displayName![0].toUpperCase()
                : "U",
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.displayName ?? "Smart Helmet User",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email ?? "",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  /* ================= INFO CARD ================= */

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
    Color valueColor = Colors.black87,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /* ================= LOGOUT ================= */
Widget _logoutButton(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton.icon(
      icon: const Icon(Icons.logout, color: Colors.black),
      label: const Text(
        "Logout",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB6E300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      onPressed: () {
        _showLogoutDialog(context);
      },
    ),
  );
}
void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      title: const Text("Logout"),
      content: const Text("Are you sure you want to logout?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () async {
            Navigator.pop(context);
            await FirebaseAuth.instance.signOut();
          },
          child: const Text("Logout"),
        ),
      ],
    ),
  );
}

}
