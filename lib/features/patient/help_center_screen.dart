import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  final List<Map<String, String>> faqs = const [
    {
      "q": "How do I start a chat with the AI?",
      "a": "Go to the 'Chat' tab at the bottom of the screen, and tap 'New Chat' or the '+' button to begin a new session with your AI assistant."
    },
    {
      "q": "How can I track my daily progress?",
      "a": "Your daily progress is visible on the 'Home' tab. You can mark your daily plan tasks as 'Done' by tapping the circles next to them."
    },
    {
      "q": "Where can I view my Recovery Calendar?",
      "a": "You can tap on the 'Calendar' tab at the bottom to view your history of completed tasks, upcoming plans, and your daily consistency."
    },
    {
      "q": "How do I update my daily mood?",
      "a": "On the 'Home' screen, scroll down to 'Resources' and tap 'Update Mood' to log how you are feeling today. This helps track your emotional wellbeing."
    },
    {
      "q": "How do I change my password?",
      "a": "Go to the 'Profile' tab, tap 'Change Password', and enter your current password followed by your new password."
    },
    {
      "q": "Can I delete my chat history?",
      "a": "Yes! On the 'Chat' tab, simply tap the red trash can icon next to any chat session you wish to remove from your personal list."
    },
    {
      "q": "How does the AI Recovery Assistant help me?",
      "a": "The AI is trained to provide emotional support, encouragement, and practical guidance throughout your recovery journey. It is available 24/7 whenever you need someone to talk to."
    },
    {
      "q": "Where can I find my Doctor's Treatment Plan?",
      "a": "On the 'Home' screen, tap 'Treatment Plan' under the Resources section to view your doctor's specific notes and medical instructions."
    },
    {
      "q": "How are my 'Recovery Days' calculated?",
      "a": "Your recovery days start counting from the day your doctor creates your profile in the system. You can view your current and longest streaks in the 'Progress' tab."
    },
    {
      "q": "Who do I contact if I have a technical issue?",
      "a": "Go to the 'Profile' tab, tap 'Help Center', and choose 'Report a Problem' or 'Contact Support' to send a message directly to our technical team."
    },
  ];

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
          "Help Center - FAQ",
          style: TextStyle(color: textColor),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
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
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                iconColor: textColor,
                collapsedIconColor: subtextColor,
                title: Text(
                  faqs[index]['q']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                children: [
                  Text(
                    faqs[index]['a']!,
                    style: TextStyle(
                      color: subtextColor,
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
