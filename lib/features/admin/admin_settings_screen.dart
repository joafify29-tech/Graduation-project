import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_screen.dart';
import 'admin_edit_profile_screen.dart';
import '../doctor/security_password_screen.dart';
import '../doctor/notifications_screen.dart';
import '../../main.dart'; // To access themeNotifier

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  String name = "Loading...";
  String email = "Loading...";
  String role = "ADMINISTRATOR";
  String status = "Active";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            name = data['name'] ?? "Admin User";
            email = data['email'] ?? user.email ?? "admin@example.com";
            role = (data['role'] ?? "ADMINISTRATOR").toString().toUpperCase();
            status = data['status'] ?? "Active";
          });
        }
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xff1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        content: Text("Are you sure you want to log out of your account?", style: TextStyle(color: textColor.withOpacity(0.8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLanguageBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomSheetBg = isDark ? const Color(0xff1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);

    showModalBottomSheet(
      context: context,
      backgroundColor: bottomSheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Language", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.language, color: Colors.blue),
                title: Text("English", style: TextStyle(color: textColor)),
                trailing: const Icon(Icons.check, color: Colors.blue),
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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        final isDark = currentMode == ThemeMode.dark;
        final bgCol = isDark ? const Color(0xff0F172A) : const Color(0xffF8FAFC);
        final cardCol = isDark ? const Color(0xff1E293B) : Colors.white;
        final textCol = isDark ? Colors.white : const Color(0xff0F172A);

        return Scaffold(
          backgroundColor: bgCol,
          appBar: AppBar(
            backgroundColor: bgCol,
            elevation: 0,
            centerTitle: true,
            title: Text(
              "Account Settings",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textCol,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardCol,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey.shade300, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: isDark ? const Color(0xff1E3A8A) : const Color(0xffEFF6FF),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'A',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.blue[200]! : Colors.blue),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(0xff22C55E),
                                shape: BoxShape.circle,
                                border: Border.all(color: cardCol, width: 2),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textCol),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xff1E3A8A) : const Color(0xffEFF6FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "ROLE: $role",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.blue[200]! : Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xff064E3B) : const Color(0xffDCFCE7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.green[200]! : const Color(0xff16A34A)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                // Management Section
                Text(
                  "MANAGEMENT",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: cardCol,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  ),
                  child: Column(
                    children: [
                      _settingsTile(context, Icons.person_outline, "Edit Profile", textCol, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminEditProfileScreen()),
                        ).then((_) => _loadProfile());
                      }),
                      _divider(context),
                      _settingsTile(context, Icons.lock_outline, "Change Password", textCol, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SecurityPasswordScreen()),
                        );
                      }),
                      _divider(context),
                      _settingsTile(context, Icons.notifications_outlined, "Notification Preferences", textCol, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                        );
                      }),
                      _divider(context),
                      _settingsTile(context, Icons.language, "Language", textCol, trailingText: "English", onTap: _showLanguageBottomSheet),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Log Out Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xffFCA5A5)),
                      backgroundColor: isDark ? const Color(0xff451A1A) : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout, color: Color(0xffEF4444), size: 20),
                    label: const Text(
                      "Log Out",
                      style: TextStyle(
                        color: Color(0xffEF4444),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                
                // Version
                Center(
                  child: Text(
                    "Version 2.4.0 (Build 1024)",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _divider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(height: 1, thickness: 1, color: isDark ? Colors.grey[800]! : const Color(0xffF1F5F9), indent: 60);
  }

  Widget _settingsTile(BuildContext context, IconData icon, String title, Color textCol, {String? trailingText, VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileIconBg = isDark ? const Color(0xff1E3A8A) : const Color(0xffEFF6FF);
    final tileIconColor = isDark ? Colors.blue[300]! : const Color(0xff2B82F6);
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: tileIconBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: tileIconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textCol),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: TextStyle(fontSize: 12, color: subtextColor)),
          if (trailingText != null) const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, size: 14, color: subtextColor),
        ],
      ),
    );
  }
}
