import 'package:flutter/material.dart';

class AlertDetailsScreen extends StatelessWidget {
  final dynamic data;

  const AlertDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final map = data.data();

    final name = map['name'] ?? "Patient";
    final id = map['refId'] ?? "#ID";

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
                const Text(
                  "Alert Details",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔥 PROFILE
            Column(
              children: [
                const CircleAvatar(radius: 30),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xffFEECEC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "HIGH RISK",
                    style: TextStyle(
                        color: const Color(0xffEF4444), fontSize: 11),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                Text(
                  "ID: $id",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔵 INFO
            Row(
              children: [
                Expanded(
                  child: infoCard(
                    "ALERT TYPE",
                    "High Risk\nDetected",
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: infoCard(
                    "DETECTED ON",
                    "Oct 24, 10:42 AM",
                    Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔵 CLINICAL REASONING
            cardBox(
              title: "Clinical Reasoning",
              icon: Icons.psychology,
              content:
                  "Patient reporting increased anxiety and isolation. Sleep patterns disrupted for 3 consecutive nights. Significant deviation from baseline metrics indicating potential relapse episode.",
            ),

            const SizedBox(height: 20),

            // 🔵 TREND
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("7-Day Mood Trend",
                      style: TextStyle(color: Colors.grey)),

                  SizedBox(height: 10),

                  Row(
                    children: [
                      Text("Severe",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 5),
                      Text("-14%",
                          style: TextStyle(color: Colors.red)),
                      Spacer(),
                      Text("Last 7 Days",
                          style: TextStyle(color: Colors.grey))
                    ],
                  ),

                  SizedBox(height: 20),

                  SizedBox(
                    height: 60,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xffE8F0FE),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔵 AI INSIGHT
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xffE8F0FE),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                "AI Clinician Insight\nPattern matching suggests 84% probability of relapse within 48 hours without intervention. Immediate contact recommended.",
                style: TextStyle(fontSize: 12),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 BUTTON (FIXED)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2F6FED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // 🔥 أهم سطر
                },
                child: const Text("View Patient Profile"),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text("Schedule"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text("Update Plan"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget infoCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget cardBox({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xff2F6FED)),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}