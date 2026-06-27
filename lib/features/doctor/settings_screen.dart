import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'personal_information_screen.dart';
import 'security_password_screen.dart';
import 'notifications_screen.dart';
import 'help_center_screen.dart';
import '../auth/login_screen.dart';
import '../patient/privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;
    final cancelBtnBg = isDark ? const Color(0xff2A2A2A) : const Color(0xffF0F2F5);
    final cancelBtnText = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isDark ? const Color(0x1aff4444) : Colors.red.shade100,
                  child: const Icon(Icons.logout,
                      color: Colors.red, size: 28),
                ),
                const SizedBox(height: 20),
                Text(
                  "Log Out?",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
                ),
                const SizedBox(height: 10),
                Text(
                  "Are you sure you want to log out of your account? You will need to enter your credentials to access the system again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subtextColor, height: 1.4),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: cancelBtnBg,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: cancelBtnText),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xffEF4444),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            logout(context);
                          },
                          child: const Text(
                            "Yes, Log Out",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Language",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Text("🇺🇸", style: TextStyle(fontSize: 24)),
                title: const Text("English"),
                trailing: const Icon(Icons.check, color: Color(0xff2F6FED)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }





  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final cardCol = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textCol = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgCol,
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
            final role = data['role'] ?? "Chief Medical Officer";
            final id = data['doctorId'] ?? user.uid.substring(0, 7);

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 🔝 HEADER
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back, color: textCol),
                    ),
                    const Spacer(),
                    Text("Settings",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textCol)),
                    const Spacer(),
                    const SizedBox(width: 24),
                  ],
                ),
                const SizedBox(height: 30),

                // 👤 PROFILE
                Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 45,
                            backgroundImage: AssetImage("assets/doctor.png"),
                          ),
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
                                color: Colors.white, size: 14),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: textCol),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "$role • ID: $id",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                sectionTitle("Account", textCol),
                tile(
                  Icons.person_outline,
                  "Personal Information",
                  cardCol,
                  textCol,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PersonalInformationScreen(),
                    ),
                  ).then((_) => setState(() {})),
                ),
                tile(
                  Icons.lock_outline,
                  "Security & Password",
                  cardCol,
                  textCol,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SecurityPasswordScreen(),
                    ),
                  ),
                ),
                tile(
                  Icons.language,
                  "Language",
                  cardCol,
                  textCol,
                  trailing: "English",
                  onTap: _showLanguageBottomSheet,
                ),

                const SizedBox(height: 20),

                sectionTitle("App Preferences", textCol),
                tile(
                  Icons.notifications_none,
                  "Notifications",
                  cardCol,
                  textCol,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                sectionTitle("Support", textCol),
                tile(
                  Icons.privacy_tip_outlined,
                  "Privacy Policy",
                  cardCol,
                  textCol,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  ),
                ),
                tile(
                  Icons.headset_mic_outlined,
                  "Help & Support",
                  cardCol,
                  textCol,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HelpCenterScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () => showLogoutDialog(context),
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.red, size: 20),
                          SizedBox(width: 8),
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
                    "Version 2.4.0 (Build 2023)",
                    style: TextStyle(color: Colors.grey, fontSize: 11),
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

  Widget sectionTitle(String text, Color textCol) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textCol),
      ),
    );
  }

  Widget tile(IconData icon, String text, Color cardCol, Color textCol,
      {String? trailing, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardCol,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xff2F6FED).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xff2F6FED), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontWeight: FontWeight.w600, color: textCol),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            if (trailing != null) const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
          ],
        ),
      ),
    );
  }
}