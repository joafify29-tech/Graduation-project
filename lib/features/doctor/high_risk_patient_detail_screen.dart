import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_patient_profile_screen.dart';

class HighRiskPatientDetailScreen extends StatelessWidget {
  final dynamic alertData;
  final String patientId;
  final bool isDarkMode;

  const HighRiskPatientDetailScreen({
    super.key,
    required this.alertData,
    required this.patientId,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final alertMap = alertData.data() as Map<String, dynamic>;
    final alertType = alertMap['alertType'] ?? "Risk Alert";
    final description = alertMap['description'] ?? "High risk detected.";
    final timestamp = alertMap['timestamp'];

    final bg = isDarkMode ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final cardBg = isDarkMode ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtextColor = isDarkMode ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('referrals')
              .doc(patientId)
              .get(),
          builder: (context, patientSnapshot) {
            String name = "Patient";
            String age = "";
            String addiction = "";
            String mood = "Unknown";
            dynamic patientDoc;

            if (patientSnapshot.hasData && patientSnapshot.data!.exists) {
              patientDoc = patientSnapshot.data;
              final patientData =
                  patientSnapshot.data!.data() as Map<String, dynamic>;
              name = patientData['name'] ?? "Patient";
              age = (patientData['age'] ?? "").toString();
              addiction = patientData['addiction'] ?? "";
              mood = patientData['mood'] ?? "Unknown";
            }

            return ListView(
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
                      "Risk Alert Detail",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // 🔥 PATIENT PROFILE CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: const Color(0xffFEECEC),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "?",
                          style: const TextStyle(
                            color: Color(0xffEF4444),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffFEECEC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "⚠ HIGH RISK",
                          style: TextStyle(
                            color: Color(0xffEF4444),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Age: $age • $addiction • Mood: $mood",
                        style: TextStyle(color: subtextColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔵 ALERT TYPE
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xff2E1A1A)
                        : const Color(0xffFEECEC),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Color(0xffEF4444), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Alert Type: $alertType",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: textColor,
                              ),
                            ),
                            if (timestamp != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                "Detected: ${_formatTimestamp(timestamp)}",
                                style: TextStyle(
                                  color: subtextColor,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔵 WHY HIGH RISK - AI ANALYSIS (from risk_alerts description)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xffEF4444).withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xff2F6FED)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.psychology,
                              color: Color(0xff2F6FED),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "AI Risk Analysis",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xff2A2A2A)
                              : const Color(0xffFFF8F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor.withValues(alpha: 0.85),
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔵 RISK FACTORS
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Key Risk Indicators",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _riskIndicator(
                        "Behavioral Pattern",
                        "Significant deviation from baseline behavioral metrics",
                        Icons.trending_down,
                        Colors.red,
                        textColor,
                        subtextColor,
                      ),
                      const SizedBox(height: 12),
                      _riskIndicator(
                        "Mood Instability",
                        "Mood scores dropping consistently over the past week",
                        Icons.mood_bad,
                        Colors.orange,
                        textColor,
                        subtextColor,
                      ),
                      const SizedBox(height: 12),
                      _riskIndicator(
                        "Engagement Drop",
                        "Reduced app interaction and missed check-ins",
                        Icons.phone_missed,
                        Colors.amber,
                        textColor,
                        subtextColor,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔵 AI RECOMMENDATION
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xff1A2744)
                        : const Color(0xffE8F0FE),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xff2F6FED),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "AI Recommendation",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Immediate intervention recommended. Consider scheduling an urgent session and reviewing the patient's treatment plan.",
                              style: TextStyle(
                                fontSize: 12,
                                color: textColor.withValues(alpha: 0.7),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 🔥 ACKNOWLEDGE BUTTON - marks risk_alert as RESOLVED
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffEF4444),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('risk_alerts')
                            .doc(alertData.id)
                            .update({'status': 'RESOLVED'});

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Alert acknowledged successfully"),
                              backgroundColor: Color(0xff34A853),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      "Acknowledge Alert",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // VIEW PATIENT PROFILE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xff2F6FED)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      if (patientDoc != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DoctorPatientProfileScreen(data: patientDoc),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "View Patient Profile",
                      style: TextStyle(
                        color: Color(0xff2F6FED),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final dt = timestamp.toDate();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return "${months[dt.month - 1]} ${dt.day}, $hour:$min $amPm";
    }
    return timestamp.toString();
  }

  Widget _riskIndicator(
    String title,
    String description,
    IconData icon,
    Color iconColor,
    Color textColor,
    Color subtextColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: subtextColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
