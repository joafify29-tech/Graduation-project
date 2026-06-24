import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  final List<Map<String, String>> faqs = const [
    {
      "q": "How do I review AI-generated high risk alerts?",
      "a": "Go to the 'Analytics' tab or tap on a patient with a 'HIGH RISK' status. You will see a dedicated section for AI-Generated Alerts detailing the specific flags."
    },
    {
      "q": "How can I export a patient's clinical report?",
      "a": "Navigate to the 'Analytics' tab and tap 'Export Report'. Select the patient you want, and you will see an 'AI Report' screen with a 'Download as PDF' button at the bottom."
    },
    {
      "q": "Where can I view a patient's mood history?",
      "a": "Patient mood history is visualized in the 'Analytics' tab or the individual 'AI Analysis' screen as a bar chart covering the last 7 sessions."
    },
    {
      "q": "How do I contact a patient urgently?",
      "a": "On the 'Analytics' tab, tap the 'Urgent Contact' button, select the patient from the list, and a secure chat window will immediately open."
    },
    {
      "q": "How do I update my personal information or hospital affiliation?",
      "a": "Go to the 'Settings' tab, tap 'Personal Information', update your details in the form, and tap 'Save Changes'."
    },
    {
      "q": "Can I enable Dark Mode for the application?",
      "a": "Yes! On the Login page, tap the moon/sun icon in the top right to toggle between Light Mode and Dark Mode."
    },
    {
      "q": "How does the AI sentiment scoring work?",
      "a": "The AI analyzes patient chat interactions to calculate a sentiment score out of 100%. A score below 40% usually triggers a review or flag for low mood/high risk."
    },
    {
      "q": "Who do I contact if I have a technical issue with the portal?",
      "a": "You can contact our support team directly at support@airecovery.app or call the dedicated medical provider IT helpdesk at 1-800-555-0199."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xffF7F8FA),
        elevation: 0,
        title: const Text("Help Center - FAQ", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
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
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  faqs[index]['q']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                children: [
                  Text(
                    faqs[index]['a']!,
                    style: const TextStyle(
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
