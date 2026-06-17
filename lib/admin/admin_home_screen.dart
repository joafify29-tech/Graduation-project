import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  Stream<int> getPatientsCount() {
    return FirebaseFirestore.instance
        .collection('referrals')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // 🔝 HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "System Administration",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const CircleAvatar(radius: 18)
              ],
            ),

            const SizedBox(height: 20),

            // 🔥 STATS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: statCard("PATIENTS", Icons.people, true)),
                const SizedBox(width: 10),
                Expanded(child: statCard("DOCTORS", Icons.medical_services, false)),
                const SizedBox(width: 10),
                Expanded(child: statCard("CENTERS", Icons.apartment, false)),
              ],
            ),

            const SizedBox(height: 25),

            // 🔥 ALERTS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("PRIORITY ALERTS",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w600)),
                Text("Clear All",
                    style: TextStyle(color: Color(0xff2F6FED))),
              ],
            ),

            const SizedBox(height: 10),

            alertCard(
              title: "Password Reset Requested",
              subtitle:
                  "Dr. Alan Smith (ID: #8821) is locked out after 5 failed login attempts.",
              color: const Color(0xffFFF4E5),
              buttonColor: const Color(0xff2F6FED),
              buttonText: "Send Link",
            ),

            const SizedBox(height: 10),

            alertCard(
              title: "Account Auto-Suspended",
              subtitle:
                  "Patient Mark Taylor (ID: #1023) was flagged by the system for security policy violations.",
              color: const Color(0xffFEECEC),
              buttonColor: const Color(0xffEF4444),
              buttonText: "Review Profile",
            ),

            const SizedBox(height: 25),

            // 🔥 MANAGEMENT
            const Text(
              "MANAGEMENT",
              style: TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            managementItem(Icons.people, "User Management"),
            managementItem(Icons.history, "Activity Logs"),
            managementItem(Icons.settings, "System Settings"),
            managementItem(Icons.notifications, "App Notifications"),
          ],
        ),
      ),

      // 🔥 BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xff2F6FED),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: "Users"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: "Reports"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  // 🔵 STAT CARD
  Widget statCard(String title, IconData icon, bool isDynamic) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xff2F6FED)),
          const SizedBox(height: 10),

          isDynamic
              ? StreamBuilder<int>(
                  stream: FirebaseFirestore.instance
                      .collection('referrals')
                      .snapshots()
                      .map((s) => s.docs.length),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Text("...");
                    return Text(
                      snapshot.data.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    );
                  },
                )
              : const Text(
                  "42",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),

          const SizedBox(height: 5),

          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 🔴 ALERT CARD
  Widget alertCard({
    required String title,
    required String subtitle,
    required Color color,
    required Color buttonColor,
    required String buttonText,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 5),

          Text(subtitle, style: const TextStyle(fontSize: 12)),

          const SizedBox(height: 10),

          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                ),
                onPressed: () {},
                child: Text(buttonText),
              ),
              const SizedBox(width: 10),
              TextButton(onPressed: () {}, child: const Text("Dismiss"))
            ],
          )
        ],
      ),
    );
  }

  // 🔵 MANAGEMENT ITEM
  Widget managementItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xff2F6FED)),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}