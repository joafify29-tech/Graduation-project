import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // 🔥 LOGOUT FUNCTION
  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // 🔥 LOGOUT POPUP (Pixel Perfect)
  void showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;
    final cancelBtnBg = isDark ? const Color(0xff2A2A2A) : const Color(0xffF0F2F5);
    final cancelBtnText = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (_) {
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
                          onPressed: () => Navigator.pop(context),
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
                          onPressed: () => logout(context),
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

  // 🔵 SECTION TITLE
  Widget sectionTitle(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          color: subtextColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 🔵 ITEM
  Widget settingItem(BuildContext context, IconData icon, String title, VoidCallback onTap,
      {Widget? trailing}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDark ? Colors.grey[400] : Colors.grey),
        title: Text(title, style: TextStyle(color: textColor)),
        trailing: trailing ??
            Icon(Icons.arrow_forward_ios,
                size: 16, color: isDark ? Colors.grey[400] : Colors.grey),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bg,

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            Text(
              "Account Settings",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 PROFILE CARD
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: isDark ? const Color(0xff1a2e4a) : const Color(0xffE3EDFF),
                    child: Icon(Icons.local_hospital,
                        color: isDark ? const Color(0xff4a8fff) : const Color(0xff2F6FED)),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Referral Center Name",
                          style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "contact@referralcenter.org",
                          style: TextStyle(color: subtextColor),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "ROLE",
                          style: TextStyle(
                              fontSize: 10, color: subtextColor),
                        ),
                        Text(
                          "Referral Center",
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x1f34a853) : const Color(0xffE6F4EA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "ACTIVE",
                      style: TextStyle(
                        color: isDark ? const Color(0xff81c784) : const Color(0xff34A853),
                        fontSize: 11,
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 🔵 ACCOUNT
            sectionTitle(context, "ACCOUNT"),

            settingItem(context, Icons.person, "Edit Profile", () {}),
            settingItem(context, Icons.lock, "Change Password", () {}),

            const SizedBox(height: 20),

            // 🔵 PREFERENCES
            sectionTitle(context, "PREFERENCES"),

            settingItem(context, Icons.language, "Language", () {},
                trailing: Text("English", style: TextStyle(color: subtextColor))),

            const SizedBox(height: 20),

            // 🔵 SUPPORT
            sectionTitle(context, "SUPPORT"),

            settingItem(context, Icons.headset_mic, "Contact Support", () {}),

            const SizedBox(height: 30),

            // 🔥 LOGOUT BUTTON
            Container(
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: isDark ? Colors.red.shade900 : Colors.red.shade200),
              ),
              child: TextButton(
                onPressed: () => showLogoutDialog(context),
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}