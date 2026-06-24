import 'package:flutter/material.dart';
import '../patient/change_password_screen.dart';

class SecurityPasswordScreen extends StatefulWidget {
  const SecurityPasswordScreen({super.key});

  @override
  State<SecurityPasswordScreen> createState() => _SecurityPasswordScreenState();
}

class _SecurityPasswordScreenState extends State<SecurityPasswordScreen> {
  bool biometricAuth = false;
  bool twoFactorAuth = false;
  bool loginAlerts = true;

  Widget securityToggle(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        value: value,
        activeThumbColor: const Color(0xff2F6FED),
        onChanged: (val) {
          onChanged(val);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("\$title has been \${val ? 'enabled' : 'disabled'}."),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xffF7F8FA),
        elevation: 0,
        title: const Text("Security & Password", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Account Security",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Manage how you log in and how we protect your account data.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            securityToggle(
              "Biometric Authentication",
              "Use Face ID or Fingerprint to unlock the app.",
              biometricAuth,
              (v) => setState(() => biometricAuth = v),
            ),

            securityToggle(
              "Two-Factor Authentication (2FA)",
              "Require a verification code sent via SMS when logging in.",
              twoFactorAuth,
              (v) => setState(() => twoFactorAuth = v),
            ),

            securityToggle(
              "Unrecognized Login Alerts",
              "Get notified when someone logs into your account from a new device.",
              loginAlerts,
              (v) => setState(() => loginAlerts = v),
            ),

            const SizedBox(height: 30),

            const Text(
              "Password Management",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_reset, color: Color(0xff2F6FED)),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        "Change Password",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xffFFF2E5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Active Sessions",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "You are currently logged in on this device. If you notice any suspicious activity, we recommend changing your password immediately.",
                    style: TextStyle(color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("All other devices have been logged out.")),
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.white, size: 18),
                    label: const Text("Log Out from All Other Devices", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
