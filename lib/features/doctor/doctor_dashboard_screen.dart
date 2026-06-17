import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_patient_profile_screen.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // 🔝 HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Doctor Dashboard",
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: const [
                    Icon(Icons.language),
                    SizedBox(width: 10),
                    Icon(Icons.dark_mode),
                  ],
                )
              ],
            ),

            const SizedBox(height: 15),

            // 🔵 FILTER
            Row(
              children: [
                filterChip("Child", true),
                filterChip("Youth", false),
                filterChip("Adult", false),
              ],
            ),

            const SizedBox(height: 20),

            // 🔴 ALERT
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xffFEECEC),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: const [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Action Required: 5 high-risk patients need immediate attention today.",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16)
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 DATA
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('referrals')
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;

                Map<String, List<dynamic>> grouped = {};

                for (var e in docs) {
                  final data = e.data() as Map<String, dynamic>;

                  String type =
                      (data['addiction'] ?? "Other").toString();

                  if (!grouped.containsKey(type)) {
                    grouped[type] = [];
                  }

                  grouped[type]!.add(e);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: grouped.entries.map((entry) {

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        sectionTitle(entry.key.toUpperCase()),

                        ...entry.value.map(
                          (e) => patientCard(context, e),
                        ),

                        const SizedBox(height: 15),
                      ],
                    );

                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🔵 SECTION TITLE
  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text,
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.w600)),
          const Text("View All",
              style: TextStyle(color: Color(0xff2F6FED))),
        ],
      ),
    );
  }

  // 🔵 FILTER CHIP
  Widget filterChip(String text, bool selected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xff2F6FED) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  // 🔥 PATIENT CARD
  Widget patientCard(BuildContext context, dynamic data) {
    final map = data.data() as Map<String, dynamic>;

    final name = map['name'] ?? "";
    final age = map['age'] ?? "";
    final mood = map['mood'] ?? "Stable";
    final status = map['status'] ?? "LOW";

    final isHigh = status == "HIGH";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DoctorPatientProfileScreen(data: data),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [

            const CircleAvatar(radius: 25),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),

                  const SizedBox(height: 5),

                  Text("Age: $age",
                      style: const TextStyle(color: Colors.grey)),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Text("🙂 ", style: TextStyle(fontSize: 12)),
                      Text("Mood: $mood",
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isHigh
                        ? const Color(0xffFEECEC)
                        : const Color(0xffE6F4EA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isHigh ? "HIGH RISK" : "LOW RISK",
                    style: TextStyle(
                      color: isHigh
                          ? const Color(0xffEF4444)
                          : const Color(0xff34A853),
                      fontSize: 11,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Text("2h ago",
                    style: TextStyle(color: Colors.grey, fontSize: 11))
              ],
            )
          ],
        ),
      ),
    );
  }
}