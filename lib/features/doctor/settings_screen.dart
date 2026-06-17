import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get(),
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            final name = data['name'] ?? "Doctor";
            final role = data['role'] ?? "";
            final id = data['doctorId'] ?? "";

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [

                // 🔝 HEADER
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back),
                    ),
                    const Spacer(),
                    const Text("Settings",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    const SizedBox(width: 24),
                  ],
                ),

                const SizedBox(height: 20),

                // 👤 PROFILE
                Column(
                  children: [

                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              AssetImage("assets/doctor.png"),
                        ),

                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xff2F6FED),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(Icons.edit,
                                color: Colors.white, size: 16),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "$role • ID: $id",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                sectionTitle("Account"),

                tile(Icons.person, "Personal Information"),
                tile(Icons.lock, "Security & Password"),
                tile(Icons.language, "Language", trailing: "English"),

                const SizedBox(height: 20),

                sectionTitle("App Preferences"),

                tile(Icons.dark_mode, "Appearance", trailing: "Light Mode"),
                tile(Icons.notifications, "Notifications"),

                const SizedBox(height: 20),

                sectionTitle("Support"),

                tile(Icons.privacy_tip, "Privacy Policy"),
                tile(Icons.support_agent, "Help & Support"),

                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () => logout(context),
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 10),
                          Text("Log Out",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                const Center(
                  child: Text(
                    "Version 1.0 (Build 2026)",
                    style: TextStyle(
                        color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 🔧 Helpers

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget tile(IconData icon, String text, {String? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xffE8F0FE),
            child: Icon(icon,
                color: const Color(0xff2F6FED)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
          if (trailing != null)
            Text(trailing,
                style: const TextStyle(color: Colors.grey)),
          const Icon(Icons.arrow_forward_ios, size: 14)
        ],
      ),
    );
  }
}