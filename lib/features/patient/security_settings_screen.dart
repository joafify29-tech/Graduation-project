import 'package:flutter/material.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool biometricAuth = false;
  bool twoFactorAuth = false;
  bool loginAlerts = true;

  Widget securityToggle(String title, String subtitle, bool value, Function(bool) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(color: subtextColor, fontSize: 12),
          ),
        ),
        value: value,
        activeColor: const Color(0xff2F6FED),
        onChanged: (val) {
          onChanged(val);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$title has been ${val ? 'enabled' : 'disabled'}."),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "Security Settings",
          style: TextStyle(color: textColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Account Security",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Manage how you log in and how we protect your account data.",
              style: TextStyle(color: subtextColor),
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

            const SizedBox(height: 40),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff3A2A1A) : const Color(0xffFFF2E5),
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
                  Text(
                    "You are currently logged in on this device. If you notice any suspicious activity, we recommend changing your password immediately.",
                    style: TextStyle(color: textColor, height: 1.5),
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
