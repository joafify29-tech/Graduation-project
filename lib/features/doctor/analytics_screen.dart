import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_select_screen.dart';
import 'high_risk_alerts_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  static const Color kPrimary = Color(0xff2B82F6);
  static const Color kRed = Color(0xffEF4444);
  static const Color kGrey = Color(0xff94A3B8);
  static const Color kSlateGrey = Color(0xff64748B);

  Color get kBg => Theme.of(context).brightness == Brightness.dark ? const Color(0xff121212) : const Color(0xffF8FAFC);
  Color get kCard => Theme.of(context).brightness == Brightness.dark ? const Color(0xff1E1E1E) : Colors.white;
  Color get kDark => Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xff0F172A);
  Color get kBorder => Theme.of(context).brightness == Brightness.dark ? const Color(0xff2A2A2A) : const Color(0xffF1F5F9);

  String? _selectedPatientId;
  String _selectedPatientName = "Select Patient";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 110),
              children: [
                // 🔝 HEADER
                Text(
                  "AI Analytics",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kDark,
                  ),
                ),
                const SizedBox(height: 20),

                // 🔵 PATIENT SELECTOR
                _buildPatientSelector(),
                const SizedBox(height: 20),

                // Dynamic content based on selection
                if (_selectedPatientId != null)
                  _buildPatientAnalytics(_selectedPatientId!)
                else
                  _buildEmptyState(),
              ],
            ),

            // 🔥 BOTTOM BUTTONS
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      kBg.withValues(alpha: 0),
                      kBg,
                    ],
                    stops: const [0.0, 0.5],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PatientSelectScreen(mode: 'report'),
                            ),
                          );
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xffF1F5F9),
                            borderRadius: BorderRadius.circular(24),
                            border:
                                Border.all(color: const Color(0xffE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "Export Report",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xff334155),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PatientSelectScreen(mode: 'chat'),
                            ),
                          );
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: kPrimary,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xff3B82F6)
                                    .withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "Urgent Contact",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSelector() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('referrals').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final patients = snapshot.data!.docs;

        return GestureDetector(
          onTap: () {
            _showPatientPicker(context, patients);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xffE8F0FE),
                  child: Text(
                    _selectedPatientName.isNotEmpty
                        ? _selectedPatientName[0].toUpperCase()
                        : "?",
                    style: const TextStyle(
                      color: kPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "CLINICAL ANALYSIS",
                        style: TextStyle(
                          fontSize: 10,
                          color: kGrey,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Patient: $_selectedPatientName",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down,
                    color: kGrey),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPatientPicker(
      BuildContext context, List<QueryDocumentSnapshot> patients) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Patient",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kDark,
                ),
              ),
              const SizedBox(height: 15),
              ...patients.map((p) {
                final pData = p.data() as Map<String, dynamic>;
                final name = pData['name'] ?? "Patient";
                final status = pData['status'] ?? "LOW";
                final isHigh = status == "HIGH";
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isHigh
                        ? const Color(0xffFEECEC)
                        : const Color(0xffE8F0FE),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "?",
                      style: TextStyle(
                        color: isHigh ? kRed : kPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isHigh ? kRed : kDark,
                    ),
                  ),
                  subtitle: Text(
                    "Age: ${pData['age']} • ${pData['addiction'] ?? ''}",
                    style: const TextStyle(fontSize: 12, color: kGrey),
                  ),
                  trailing: isHigh
                      ? const Icon(Icons.warning_amber_rounded,
                          color: kRed, size: 18)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedPatientId = p.id;
                      _selectedPatientName = name;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.analytics_outlined,
              size: 64, color: kGrey.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text(
            "Select a patient to view analytics",
            style: TextStyle(
              fontSize: 15,
              color: kGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientAnalytics(String patientId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ai_reports')
          .doc(patientId)
          .snapshots(),
      builder: (context, reportSnapshot) {
        int moodScore = 100;
        String riskLevel = "LOW";
        List<double> barValues = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5];

        if (reportSnapshot.hasData && reportSnapshot.data!.exists) {
          final data =
              reportSnapshot.data!.data() as Map<String, dynamic>;
          moodScore = data['currentMoodScore'] ?? 100;
          riskLevel = data['currentRiskLevel'] ?? "LOW";

          final List<dynamic> history = data['moodHistory'] ?? [];
          if (history.isNotEmpty) {
            List<double> mapped =
                history.map((e) => (e as int) / 100.0).toList();
            if (mapped.length < 7) {
              final pad = 7 - mapped.length;
              barValues = List.filled(pad, 0.0) + mapped;
            } else {
              barValues = mapped.sublist(mapped.length - 7);
            }
          }
        }

        return Column(
          children: [
            _buildTopMetrics(moodScore, riskLevel),
            const SizedBox(height: 20),
            _buildMoodTrendsCard(patientId, barValues),
            const SizedBox(height: 20),
            _buildAlertsSection(patientId),
          ],
        );
      },
    );
  }

  Widget _buildTopMetrics(int sentimentScore, String riskLevel) {
    final isHigh = riskLevel == 'HIGH';
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 185,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 112,
                  height: 112,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 112,
                        height: 112,
                        child: CircularProgressIndicator(
                          value: sentimentScore / 100.0,
                          strokeWidth: 10.89,
                          backgroundColor: const Color(0xffE2E8F0),
                          valueColor: const AlwaysStoppedAnimation(
                              kPrimary),
                        ),
                      ),
                      Text(
                        "$sentimentScore%",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    "SENTIMENT SCORE",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: kGrey,
                      letterSpacing: 0.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: isHigh
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const HighRiskAlertsScreen(),
                      ),
                    );
                  }
                : null,
            child: Container(
              height: 185,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isHigh
                    ? const Color(0xffFEF2F2).withValues(alpha: 0.5)
                    : const Color(0xffE6F4EA).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isHigh
                      ? const Color(0xffFEE2E2)
                      : const Color(0xffBBF7D0),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isHigh
                          ? const Color(0xffFEE2E2)
                              .withValues(alpha: 0.8)
                          : const Color(0xffBBF7D0)
                              .withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isHigh
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      color:
                          isHigh ? kRed : const Color(0xff34A853),
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isHigh ? "High Risk" : "Low Risk",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          isHigh ? kRed : const Color(0xff34A853),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isHigh ? "IMMEDIATE REVIEW" : "STABLE",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.225,
                      color: isHigh
                          ? const Color(0xffF87171)
                              .withValues(alpha: 0.8)
                          : const Color(0xff34A853)
                              .withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodTrendsCard(
      String patientId, List<double> fallbackValues) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Mood Trends",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kDark)),
                  SizedBox(height: 4),
                  Text("Last 7 days behavior",
                      style:
                          TextStyle(fontSize: 12, color: kGrey)),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: kPrimary, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  const Text("Stability",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: kSlateGrey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('mood_updates')
                .where('patientId', isEqualTo: patientId)
                .orderBy('timestamp', descending: true)
                .limit(7)
                .snapshots(),
            builder: (context, moodSnapshot) {
              List<double> moodValues = fallbackValues;
              List<String> moodDays = days;

              if (moodSnapshot.hasData &&
                  moodSnapshot.data!.docs.isNotEmpty) {
                final moodDocs =
                    moodSnapshot.data!.docs.reversed.toList();
                moodValues = moodDocs.map((d) {
                  final mData =
                      d.data() as Map<String, dynamic>;
                  final score = mData['moodScore'] ??
                      mData['mood_score'] ??
                      50;
                  return (score is int
                          ? score.toDouble()
                          : (score as double)) /
                      100.0;
                }).toList();

                while (moodValues.length < 7) {
                  moodValues.insert(0, 0.0);
                }

                moodDays = [];
                final dayNames = [
                  'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
                ];
                final padCount = 7 - moodDocs.length;
                for (int i = 0; i < padCount; i++) {
                  moodDays.add('--');
                }
                for (var d in moodDocs) {
                  final mData =
                      d.data() as Map<String, dynamic>;
                  final ts = mData['timestamp'];
                  if (ts is Timestamp) {
                    final dt = ts.toDate();
                    moodDays.add(dayNames[dt.weekday - 1]);
                  } else {
                    moodDays.add('--');
                  }
                }
              }

              return SizedBox(
                height: 192,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 1.0,
                    barTouchData:
                        BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 ||
                                idx >= moodDays.length) {
                              return const SizedBox.shrink();
                            }
                            final isLast =
                                idx == moodDays.length - 1;
                            final isRed =
                                idx < moodValues.length &&
                                    moodValues[idx] < 0.4;
                            return Padding(
                              padding: const EdgeInsets.only(
                                  top: 8),
                              child: Text(
                                moodDays[idx],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isLast || isRed
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isRed
                                      ? kRed
                                      : isLast
                                          ? kPrimary
                                          : kGrey,
                                ),
                              ),
                            );
                          },
                          reservedSize: 28,
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 0.25,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: kBorder,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                        moodValues.length, (i) {
                      final val = moodValues[i];
                      final isRed = val < 0.4 && val > 0;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: val.clamp(0.05, 1.0),
                            color:
                                isRed ? kRed : kPrimary,
                            width: 12,
                            borderRadius:
                                BorderRadius.circular(9999),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(String patientId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('risk_alerts')
          .where('patientId', isEqualTo: patientId)
          .orderBy('timestamp', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        List<Widget> alertWidgets = [];
        int count = 0;

        if (snapshot.hasData &&
            snapshot.data!.docs.isNotEmpty) {
          count = snapshot.data!.docs.length;
          alertWidgets = snapshot.data!.docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return _buildAlertCard(
              title: d['alertType'] ?? 'Alert',
              description: d['description'] ?? '',
              isHighRisk: d['riskLevel'] == 'HIGH',
              timestamp: d['timestamp'],
            );
          }).toList();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "AI-Generated Alerts",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (count > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xffDBEAFE),
                          borderRadius:
                              BorderRadius.circular(2),
                        ),
                        child: Text(
                          "$count NEW",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: kPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const HighRiskAlertsScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "View Logs",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (alertWidgets.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text("No recent alerts",
                    style: TextStyle(color: kGrey)),
              )
            else
              ...alertWidgets,
          ],
        );
      },
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String description,
    required bool isHighRisk,
    dynamic timestamp,
  }) {
    Color iconBg;
    Color iconColor;
    IconData icon;

    if (title.toLowerCase().contains('anxiety')) {
      iconBg = const Color(0xffFEF2F2);
      iconColor = kRed;
      icon = Icons.warning_amber_rounded;
    } else if (title.toLowerCase().contains('sleep')) {
      iconBg = const Color(0xffFFFBEB);
      iconColor = const Color(0xffF59E0B);
      icon = Icons.nightlight_round;
    } else if (title.toLowerCase().contains('linguistic')) {
      iconBg = const Color(0xffEFF6FF);
      iconColor = kPrimary;
      icon = Icons.text_fields;
    } else {
      iconBg = isHighRisk
          ? const Color(0xffFEF2F2)
          : const Color(0xffEFF6FF);
      iconColor = isHighRisk ? kRed : kPrimary;
      icon = isHighRisk
          ? Icons.warning_amber_rounded
          : Icons.info_outline;
    }

    String timeAgo = "";
    if (timestamp is Timestamp) {
      final diff =
          DateTime.now().difference(timestamp.toDate());
      if (diff.inMinutes < 60) {
        timeAgo = "${diff.inMinutes}m ago";
      } else if (diff.inHours < 24) {
        timeAgo = "${diff.inHours}h ago";
      } else {
        timeAgo = "${diff.inDays}d ago";
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: kDark,
                        ),
                      ),
                    ),
                    if (timeAgo.isNotEmpty)
                      Text(
                        timeAgo,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: kGrey,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: kSlateGrey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}