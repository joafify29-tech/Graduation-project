import 'package:flutter/material.dart';
import 'alert_details_screen.dart';
import 'treatment_plan_screen.dart';
import 'medications_screen.dart';
import 'reminders_screen.dart';
import 'chat_screen.dart';
import 'ai_analysis_screen.dart'; // 🔥 جديد

class DoctorPatientProfileScreen extends StatelessWidget {
  final dynamic data;

  const DoctorPatientProfileScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final map = data.data();

    final name = map['name'] ?? "Patient";
    final age = map['age'] ?? "";
    final addiction = map['addiction'] ?? "";

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // 🔝 HEADER
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 10),
                const Text("Patient Profile",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                const Icon(Icons.language),
                const SizedBox(width: 10),
                const Icon(Icons.dark_mode),
              ],
            ),

            const SizedBox(height: 20),

            // 🔥 PROFILE
            Row(
              children: [
                const CircleAvatar(radius: 30),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xffE6F4EA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "ACTIVE",
                            style: TextStyle(
                                color: Color(0xff34A853), fontSize: 10),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "$age years old • $addiction recovery",
                      style: const TextStyle(color: Colors.grey),
                    )
                  ],
                )
              ],
            ),

            const SizedBox(height: 20),

            // 🔵 STATUS
            Row(
              children: [
                Expanded(child: statusCard("LAST MOOD", "Stable", Colors.blue)),
                const SizedBox(width: 10),
                Expanded(child: statusCard("AI RISK", "Elevated", Colors.red)),
                const SizedBox(width: 10),
                Expanded(child: statusCard("TASKS", "3 Due", Colors.orange)),
              ],
            ),

            const SizedBox(height: 20),

            // 🔵 ALERT
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xffE8F0FE),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("AI Diagnostic Alert",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const Text(
                    "Recent erratic sleep patterns and potential relapse triggers detected based on biometric data.",
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2F6FED),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AlertDetailsScreen(data: data),
                            ),
                          );
                        },
                        child: const Text("Review Data"),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Dismiss"),
                      )
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔵 TOOLS
            const Text("CLINICAL TOOLS",
                style: TextStyle(color: Colors.grey)),

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
              children: const [
                Text("CLINICAL LOG",
                    style: TextStyle(color: Colors.grey)),
                Text("View All",
                    style: TextStyle(color: Color(0xff2F6FED))),
              ],
            ),

            const SizedBox(height: 10),

            logItem("Outreach Call", "Today, 10:45 AM"),
            logItem("Progress Note Added", "Yesterday, 4:20 PM"),
          ],
        ),
      ),
    );
  }

  Widget statusCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 5),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  static Widget toolItem(BuildContext context, IconData icon, String text, dynamic data) {
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

        } else if (text == "AI Analysis") { // 🔥 ده المهم
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xff2F6FED)),
            const SizedBox(height: 5),
            Text(text, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget logItem(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.phone, color: Color(0xff2F6FED)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14)
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