import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'doctor_patient_profile_screen.dart';
import 'high_risk_alerts_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  // Filter: "All" (default), "Child", "Youth", "Adult"
  String _selectedFilter = "All";

  // Age ranges
  // Child: 0-12, Youth: 13-17, Adult: 18+
  bool _matchesFilter(int age) {
    switch (_selectedFilter) {
      case "Child":
        return age >= 0 && age <= 12;
      case "Youth":
        return age >= 13 && age <= 17;
      case "Adult":
        return age >= 18;
      default: // "All"
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;
    final chipBg =
        isDark ? const Color(0xff2A2A2A) : Colors.white;

    final currentDoctorUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('referrals')
              .where('doctorId', isEqualTo: currentDoctorUid)
              .snapshots(),
          builder: (context, referralsSnapshot) {
            if (!referralsSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final referralDocs = referralsSnapshot.data!.docs;
            final assignedPatientIds = referralDocs.map((d) => d.id).toSet();

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 🔝 HEADER
                Text(
                  "Doctor Dashboard",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 15),

                // 🔵 FILTER CHIPS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(context, "All", chipBg, textColor),
                      _buildFilterChip(context, "Child", chipBg, textColor),
                      _buildFilterChip(context, "Youth", chipBg, textColor),
                      _buildFilterChip(context, "Adult", chipBg, textColor),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔴 HIGH RISK ALERT BANNER
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('risk_alerts')
                      .where('riskLevel', isEqualTo: 'HIGH')
                      .where('status', isEqualTo: 'UNRESOLVED')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }

                    // Filter alerts in-memory
                    final alertDocs = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final patientId = data['patientId'];
                      return assignedPatientIds.contains(patientId);
                    }).toList();

                    if (alertDocs.isEmpty) {
                      // Show "no alerts" message
                      return Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xff1A2E1A)
                              : const Color(0xffE6F4EA),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xff34A853),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "No risk alerts detected. All patients are stable.",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final int alertCount = alertDocs.length;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HighRiskAlertsScreen(
                              isDarkMode: isDark,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xff2E1A1A)
                              : const Color(0xffFEECEC),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Action Required: $alertCount high-risk alert${alertCount == 1 ? '' : 's'} need immediate attention.",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios,
                                size: 16, color: subtextColor)
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 🔥 PATIENTS DATA - grouped by addiction type, filtered by age
                Builder(
                  builder: (context) {
                    // Filter by age category
                    List<QueryDocumentSnapshot> filteredDocs = [];
                    for (var e in referralDocs) {
                      final data = e.data() as Map<String, dynamic>;
                      final ageValue = data['age'];
                      int age = 0;
                      if (ageValue is int) {
                        age = ageValue;
                      } else if (ageValue is String) {
                        age = int.tryParse(ageValue) ?? 0;
                      }

                      if (_matchesFilter(age)) {
                        filteredDocs.add(e);
                      }
                    }

                    if (filteredDocs.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.person_off_outlined,
                                size: 48,
                                color: subtextColor.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "No ${_selectedFilter == 'All' ? '' : '${_selectedFilter.toLowerCase()} '}patients found",
                                style: TextStyle(
                                  color: subtextColor,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Group by addiction type
                    Map<String, List<QueryDocumentSnapshot>> grouped = {};
                    for (var e in filteredDocs) {
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
                            _sectionTitle(entry.key.toUpperCase(), textColor,
                                subtextColor),
                            ...entry.value.map(
                              (e) => _patientCard(context, e, cardBg, textColor,
                                  subtextColor),
                            ),
                            const SizedBox(height: 15),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 🔵 FILTER CHIP (interactive)
  Widget _buildFilterChip(BuildContext context,
      String text, Color chipBg, Color textColor) {
    final isSelected = _selectedFilter == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = text;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff2F6FED) : chipBg,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[700]!
                      : Colors.grey[300]!,
                ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // 🔵 SECTION TITLE
  Widget _sectionTitle(
      String text, Color textColor, Color subtextColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text,
              style: TextStyle(
                  color: subtextColor, fontWeight: FontWeight.w600)),
          const Text("View All",
              style: TextStyle(color: Color(0xff2F6FED))),
        ],
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toUpperCase()) {
      case "VERY HAPPY":
        return "😄";
      case "HAPPY":
        return "🙂";
      case "NEUTRAL":
        return "😐";
      case "SAD":
        return "😔";
      case "VERY SAD":
        return "😢";
      default:
        return "🙂";
    }
  }

  // 🔥 PATIENT CARD
  Widget _patientCard(BuildContext context, dynamic data,
      Color cardBg, Color textColor, Color subtextColor) {
    final map = data.data() as Map<String, dynamic>;

    final name = map['name'] ?? "";
    final age = map['age'] ?? "";
    final mood = map['mood'] ?? map['currentMood'] ?? "Stable";
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
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xff2A2A2A)
                  : const Color(0xffE8E8E8),
              child: Text(
                name.toString().isNotEmpty
                    ? name[0].toUpperCase()
                    : "?",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  const SizedBox(height: 5),
                  Text("Age: $age",
                      style: TextStyle(color: subtextColor)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text("${_getMoodEmoji(mood)} ",
                          style: const TextStyle(fontSize: 12)),
                      Text("Mood: $mood",
                          style: TextStyle(
                              fontSize: 12, color: subtextColor)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
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
                Text("2h ago",
                    style: TextStyle(
                        color: subtextColor, fontSize: 11))
              ],
            )
          ],
        ),
      ),
    );
  }
}