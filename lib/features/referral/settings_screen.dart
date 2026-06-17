import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // 🔥 LOGOUT FUNCTION
  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // 🔥 LOGOUT POPUP (Pixel Perfect)
  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.red.shade100,
                  child: const Icon(Icons.logout,
                      color: Colors.red, size: 28),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Log Out?",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Are you sure you want to log out of your account? You will need to enter your credentials to access the system again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, height: 1.4),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xffF0F2F5),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black),
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
  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 🔵 ITEM
  Widget settingItem(IconData icon, String title, VoidCallback onTap,
      {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey),
        title: Text(title),
        trailing: trailing ??
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            const Text(
              "Account Settings",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 PROFILE CARD
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xffE3EDFF),
                    child: Icon(Icons.local_hospital,
                        color: Color(0xff2F6FED)),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Referral Center Name",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "contact@referralcenter.org",
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "ROLE",
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey),
                        ),
                        Text("Referral Center"),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xffE6F4EA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "ACTIVE",
                      style: TextStyle(
                        color: Color(0xff34A853),
                        fontSize: 11,
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 🔵 ACCOUNT
            sectionTitle("ACCOUNT"),

            settingItem(Icons.person, "Edit Profile", () {}),
            settingItem(Icons.lock, "Change Password", () {}),

            const SizedBox(height: 20),

            // 🔵 PREFERENCES
            sectionTitle("PREFERENCES"),

            settingItem(Icons.language, "Language", () {},
                trailing: const Text("English")),

            settingItem(Icons.dark_mode, "Dark Mode", () {},
                trailing: Switch(
                  value: false,
                  onChanged: (val) {},
                )),

            const SizedBox(height: 20),

            // 🔵 SUPPORT
            sectionTitle("SUPPORT"),

            settingItem(Icons.headset_mic, "Contact Support", () {}),

            const SizedBox(height: 30),

            // 🔥 LOGOUT BUTTON
            Container(
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.red.shade200),
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