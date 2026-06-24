import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool pushEnabled = true;
  bool emailEnabled = false;
  bool highRiskAlerts = true;
  bool newMessages = true;
  bool systemUpdates = false;

  Widget toggleRow(String title, String subtitle, bool value, Function(bool) onChanged) {
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
        onChanged: onChanged,
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
        title: const Text("Notifications", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Global Settings",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            toggleRow(
              "Push Notifications",
              "Receive push notifications on this device.",
              pushEnabled,
              (v) => setState(() => pushEnabled = v),
            ),
            
            toggleRow(
              "Email Notifications",
              "Receive email updates about your account and patients.",
              emailEnabled,
              (v) => setState(() => emailEnabled = v),
            ),

            const SizedBox(height: 30),
            const Text(
              "Alert Preferences",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            toggleRow(
              "High Risk Alerts",
              "Get notified immediately when a patient is flagged as high risk by AI.",
              highRiskAlerts,
              (v) => setState(() => highRiskAlerts = v),
            ),

            toggleRow(
              "New Messages",
              "Get notified when a patient or staff member sends you a message.",
              newMessages,
              (v) => setState(() => newMessages = v),
            ),

            toggleRow(
              "System Updates",
              "Get notified about app updates and new features.",
              systemUpdates,
              (v) => setState(() => systemUpdates = v),
            ),

          ],
        ),
      ),
    );
  }
}
