import 'package:flutter/material.dart';
import 'alert_details_screen.dart';
import 'treatment_plan_screen.dart';
import 'medications_screen.dart';
import 'reminders_screen.dart';
import 'chat_screen.dart';
import 'ai_analysis_screen.dart';

class DoctorPatientProfileScreen extends StatelessWidget {
  final dynamic data;

  const DoctorPatientProfileScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final map = data.data();

    final name = map['name'] ?? "Patient";
    final age = map['age'] ?? "";
    final addiction = map['addiction'] ?? "";
    final mood = map['mood'] ?? map['currentMood'] ?? "Stable";

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 🔝 HEADER
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back, color: textColor),
                ),
                const SizedBox(width: 10),
                Text(
                  "Patient Profile",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                const Spacer(),
                Icon(Icons.language, color: textColor),
              ],
            ),

            const SizedBox(height: 20),

            // 🔥 PROFILE
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isDark ? const Color(0xff1E293B) : const Color(0xffE2E8F0),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "?",
                    style: TextStyle(
                      color: isDark ? Colors.blue[300]! : Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xffE6F4EA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "ACTIVE",
                            style: TextStyle(color: Color(0xff34A853), fontSize: 10),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "$age years old • $addiction recovery",
                      style: TextStyle(color: subtextColor),
                    )
                  ],
                )
              ],
            ),

            const SizedBox(height: 20),

            // 🔵 STATUS
            Row(
              children: [
                Expanded(child: statusCard("LAST MOOD", mood, Colors.blue, isDark)),
                const SizedBox(width: 10),
                Expanded(child: statusCard("AI RISK", "Elevated", Colors.red, isDark)),
                const SizedBox(width: 10),
                Expanded(child: statusCard("TASKS", "3 Due", Colors.orange, isDark)),
              ],
            ),

            const SizedBox(height: 20),

            // 🔵 ALERT
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff1E293B).withValues(alpha: 0.8) : const Color(0xffE8F0FE),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isDark ? Colors.blue.withValues(alpha: 0.3) : Colors.transparent,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AI Diagnostic Alert",
                    style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Recent erratic sleep patterns and potential relapse triggers detected based on biometric data.",
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300]! : Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2F6FED),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AlertDetailsScreen(data: data),
                            ),
                          );
                        },
                        child: const Text("Review Data", style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Dismiss", style: TextStyle(color: Color(0xff2F6FED))),
                      )
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔵 TOOLS
            Text(
              "CLINICAL TOOLS",
              style: TextStyle(
                color: subtextColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 10),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                toolItem(context, Icons.assignment, "Treatment Plan", data),
                toolItem(context, Icons.medication, "Medications", data),
                toolItem(context, Icons.notifications, "Reminders", data),
                toolItem(context, Icons.analytics, "AI Analysis", data),
                toolItem(context, Icons.chat, "Messages", data),
                toolItem(context, Icons.science, "Lab Results", data),
              ],
            ),

            const SizedBox(height: 20),

            // 🔵 LOG
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "CLINICAL LOG",
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const Text(
                  "View All",
                  style: TextStyle(color: Color(0xff2F6FED), fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 10),

            logItem(context, "Outreach Call", "Today, 10:45 AM"),
            logItem(context, "Progress Note Added", "Yesterday, 4:20 PM"),
          ],
        ),
      ),
    );
  }

  Widget statusCard(String title, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.3 : 0.15),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400]! : Colors.grey),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
          ),
        ],
      ),
    );
  }

  static Widget toolItem(BuildContext context, IconData icon, String text, dynamic data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: () {
        if (text == "Treatment Plan") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TreatmentPlanScreen(data: data),
            ),
          );
        } else if (text == "Medications") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MedicationsScreen(data: data),
            ),
          );
        } else if (text == "Reminders") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RemindersScreen(data: data),
            ),
          );
        } else if (text == "Messages") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                data: data,
                role: "doctor",
              ),
            ),
          );
        } else if (text == "AI Analysis") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AIAnalysisScreen(data: data),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlaceholderScreen(title: text),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : const Color(0xffE2E8F0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xff2F6FED)),
            const SizedBox(height: 5),
            Text(
              text,
              style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget logItem(BuildContext context, String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : const Color(0xffE2E8F0),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.phone, color: Color(0xff2F6FED)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: subtextColor, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: subtextColor)
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text("$title Screen"),
      ),
    );
  }
}