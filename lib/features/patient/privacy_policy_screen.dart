import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "Privacy Policy",
          style: TextStyle(color: textColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Data Collection & Usage",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 10),
              Text(
                "We collect information that you provide directly to us, such as when you create or modify your account, request on-demand services, contact customer support, or otherwise communicate with us. This includes your name, email, phone number, and recovery progress data. We use this data to provide, maintain, and improve our services, including the AI chat features and doctor dashboards.",
                style: TextStyle(color: subtextColor, height: 1.5),
              ),
              const SizedBox(height: 20),
              Text(
                "Information Sharing",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 10),
              Text(
                "Your medical and recovery data is kept strictly confidential. It is only shared with your explicitly assigned doctor. We do not sell your personal data to third parties. We may share anonymized data for research or statistical purposes, but your personal identity will always be protected.",
                style: TextStyle(color: subtextColor, height: 1.5),
              ),
              const SizedBox(height: 20),
              Text(
                "AI Assistant Privacy",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 10),
              Text(
                "Conversations with the AI Recovery Assistant are stored securely to provide contextual memory for your recovery journey. You retain the right to delete your chat history at any time from your device, which will permanently remove it from your active view.",
                style: TextStyle(color: subtextColor, height: 1.5),
              ),
              const SizedBox(height: 20),
              Text(
                "Data Security",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 10),
              Text(
                "We implement industry-standard security measures, including encryption and secure server hosting through Firebase, to protect your personal information from unauthorized access, alteration, disclosure, or destruction.",
                style: TextStyle(color: subtextColor, height: 1.5),
              ),
              const SizedBox(height: 20),
              Text(
                "Last Updated: June 2026",
                style: TextStyle(color: subtextColor, fontStyle: FontStyle.italic, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
