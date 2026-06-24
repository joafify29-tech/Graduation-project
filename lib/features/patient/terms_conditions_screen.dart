import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
          "Terms & Conditions",
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
                "1. Acceptance of Terms",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 10),
              Text(
                "By accessing and using the AI Recovery App, you accept and agree to be bound by the terms and provision of this agreement. Any participation in this service will constitute acceptance of this agreement. If you do not agree to abide by the above, please do not use this service.",
                style: TextStyle(color: subtextColor, height: 1.5),
              ),
              const SizedBox(height: 20),
              Text(
                "2. Medical Disclaimer",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 10),
              Text(
                "The content provided by the AI Recovery App, including text, graphics, images, and AI-generated chat responses, is for informational and supportive purposes only. It is not intended to be a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.",
                style: TextStyle(color: subtextColor, height: 1.5),
              ),
              const SizedBox(height: 20),
              Text(
                "3. User Responsibilities",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 10),
              Text(
                "You are responsible for maintaining the confidentiality of your account and password and for restricting access to your computer or mobile device. You agree to accept responsibility for all activities that occur under your account or password. You must notify us immediately upon becoming aware of any breach of security or unauthorized use of your account.",
                style: TextStyle(color: subtextColor, height: 1.5),
              ),
              const SizedBox(height: 20),
              Text(
                "4. Termination",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 10),
              Text(
                "We may terminate or suspend access to our Service immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms. All provisions of the Terms which by their nature should survive termination shall survive termination.",
                style: TextStyle(color: subtextColor, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
