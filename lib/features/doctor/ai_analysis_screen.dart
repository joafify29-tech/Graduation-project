import 'package:flutter/material.dart';

class AIAnalysisScreen extends StatelessWidget {
  final dynamic data;

  const AIAnalysisScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final map = data.data();

    final name = map['name'] ?? "";
    final age = map['age'] ?? "";
    final addiction = map['addiction'] ?? "";

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      body: SafeArea(
        child: Stack(
          children: [

            ListView(
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

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "CLINICAL ANALYSIS",
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey),
                        ),

                        Text(
                          "Patient: $name",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),

                        Text(
                          "$age years • $addiction",
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),

                    const Spacer(),
                    const Icon(Icons.more_horiz),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔵 TOP CARDS
                Row(
                  children: [
                    Expanded(child: sentimentCard()),
                    const SizedBox(width: 10),
                    Expanded(child: riskCard()),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔵 MOOD CHART
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Mood Trends",
                              style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                          Text("Stability",
                              style: TextStyle(color: Colors.blue)),
                        ],
                      ),

                      const SizedBox(height: 5),

                      const Text("Last 7 days behavior",
                          style: TextStyle(color: Colors.grey)),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          bar(60), bar(40), bar(80),
                          bar(50), bar(70), bar(35),
                          bar(20, isRed: true),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔵 ALERTS
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("AI-Generated Alerts",
                        style: TextStyle(color: Colors.grey)),
                    Text("View Logs",
                        style: TextStyle(color: Color(0xff2F6FED))),
                  ],
                ),

                const SizedBox(height: 10),

                alertItem(
                  "Anxiety Threshold",
                  "Increased anxiety markers detected in 4 consecutive chat logs over the last 6 hours.",
                ),

                alertItem(
                  "Sleep Disruption",
                  "Pattern of late-night application activity deviates from baseline.",
                ),

                alertItem(
                  "Linguistic Shift",
                  "Noticeable change in syntax complexity observed.",
                ),

                const SizedBox(height: 80),
              ],
            ),

            // 🔥 BUTTONS
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [

                  Expanded(
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border:
                            Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Center(
                        child: Text("Export Report"),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: GestureDetector(
                      onTap: () => showUrgent(context),
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: const Color(0xff2F6FED),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text("Urgent Contact",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget sentimentCard() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text(
          "100%",
          style:
              TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget riskCard() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xffFEECEC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text(
          "High Risk",
          style: TextStyle(
              color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget bar(double height, {bool isRed = false}) {
    return Container(
      width: 12,
      height: height,
      decoration: BoxDecoration(
        color: isRed
            ? Colors.red
            : const Color(0xff2F6FED),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget alertItem(String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(desc,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  void showUrgent(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text("Urgent Action",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

              option("Secure In-App Call"),
              option("Send Urgent Message"),
              option("Call Emergency Contact"),
              option("Contact Local Services"),

              const SizedBox(height: 10),

              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text("Cancel",
                      style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget option(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.arrow_right),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}