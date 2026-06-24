import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final List<String> periods = ["7 Days", "30 Days", "3 Months", "Year"];
  String selectedPeriod = "30 Days";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF8FAFC);
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);
    final borderCol = isDark ? Colors.grey[800]! : const Color(0xffE2E8F0);
    final buttonBg = isDark ? const Color(0xff1A2A4A) : const Color(0xffEFF6FF);
    final shadowColor = isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.02);
    final progressTrackBg = isDark ? Colors.grey[800]! : const Color(0xffF1F5F9);
    final textDarkAccent = isDark ? Colors.grey[300]! : const Color(0xff475569);
    final headingColor = isDark ? Colors.white : const Color(0xff1E293B);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "System Reports",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: buttonBg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () {},
              icon: const Icon(Icons.download, size: 16, color: Colors.blue),
              label: const Text(
                "Export CSV",
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, usersSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('referrals').snapshots(),
            builder: (context, referralsSnapshot) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('chats').snapshots(),
                builder: (context, chatsSnapshot) {
                  
                  final Map<String, Map<String, dynamic>> usersMap = {};
                  if (usersSnapshot.hasData) {
                    for (var doc in usersSnapshot.data!.docs) {
                      usersMap[doc.id] = doc.data() as Map<String, dynamic>;
                    }
                  }

                  final Map<String, Map<String, dynamic>> referralsMap = {};
                  if (referralsSnapshot.hasData) {
                    for (var doc in referralsSnapshot.data!.docs) {
                      referralsMap[doc.id] = doc.data() as Map<String, dynamic>;
                    }
                  }

                  int patients = 0;
                  int doctors = 0;

                  // Count doctors from users
                  usersMap.forEach((id, userData) {
                    final role = (userData['role'] ?? "").toString().toLowerCase().trim();
                    if (role == 'doctor') {
                      doctors++;
                    }
                  });

                  // Count patients ONLY if they exist in both collections
                  referralsMap.forEach((id, referralData) {
                    if (usersMap.containsKey(id)) {
                      patients++;
                    }
                  });

                  int aiCalls = chatsSnapshot.hasData ? chatsSnapshot.data!.docs.length : 0;
                  int total = patients + doctors + aiCalls;

                  double pPercent = total == 0 ? 0 : (patients / total) * 100;
                  double dPercent = total == 0 ? 0 : (doctors / total) * 100;
                  double aPercent = total == 0 ? 0 : (aiCalls / total) * 100;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // TIME FILTERS
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: periods.length,
                            itemBuilder: (context, index) {
                              final p = periods[index];
                              final isSelected = p == selectedPeriod;
                              return GestureDetector(
                                onTap: () {
                                  setState(() => selectedPeriod = p);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xff2B82F6) : cardBg,
                                    border: isSelected ? null : Border.all(color: borderCol),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xff2B82F6).withValues(alpha: 0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Text(
                                    p,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? Colors.white : subtextColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 24),

                        // USER GROWTH CHART
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: shadowColor,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "USER GROWTH",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: headingColor),
                                  ),
                                  Row(
                                    children: [
                                      _legendItem(context, const Color(0xff3B82F6), "Patients"),
                                      const SizedBox(width: 12),
                                      _legendItem(context, const Color(0xff22C55E), "Doctors"),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                height: 180,
                                child: LineChart(
                                  LineChartData(
                                    gridData: const FlGridData(show: false),
                                    titlesData: FlTitlesData(
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final style = TextStyle(color: subtextColor, fontSize: 10);
                                            String text;
                                            switch (value.toInt()) {
                                              case 0: text = 'Week 1'; break;
                                              case 2: text = 'Week 2'; break;
                                              case 4: text = 'Week 3'; break;
                                              case 6: text = 'Week 4'; break;
                                              default: text = ''; break;
                                            }
                                            return SideTitleWidget(
                                              axisSide: meta.axisSide,
                                              space: 10,
                                              child: Text(text, style: style),
                                            );
                                          },
                                          interval: 2,
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: [
                                          const FlSpot(0, 0),
                                          FlSpot(2, (patients * 0.3).toDouble()),
                                          FlSpot(4, (patients * 0.7).toDouble()),
                                          FlSpot(6, patients.toDouble()),
                                        ],
                                        isCurved: true,
                                        color: const Color(0xff3B82F6),
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: const FlDotData(show: false),
                                      ),
                                      LineChartBarData(
                                        spots: [
                                          const FlSpot(0, 0),
                                          FlSpot(2, (doctors * 0.3).toDouble()),
                                          FlSpot(4, (doctors * 0.7).toDouble()),
                                          FlSpot(6, doctors.toDouble()),
                                        ],
                                        isCurved: true,
                                        color: const Color(0xff22C55E),
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: const FlDotData(show: false),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // PLATFORM USAGE
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: shadowColor,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "PLATFORM USAGE",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: headingColor),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  // Using a simple Stack to mimic the circular breakdown
                                  SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Stack(
                                      children: [
                                        PieChart(
                                          PieChartData(
                                            sectionsSpace: 0,
                                            centerSpaceRadius: 40,
                                            sections: total == 0 
                                              ? [PieChartSectionData(color: isDark ? Colors.grey[800]! : Colors.grey.shade300, value: 1, title: '', radius: 10)]
                                              : [
                                                PieChartSectionData(color: const Color(0xff3B82F6), value: pPercent, title: '', radius: 10),
                                                PieChartSectionData(color: const Color(0xff22C55E), value: dPercent, title: '', radius: 10),
                                                PieChartSectionData(color: const Color(0xffA855F7), value: aPercent, title: '', radius: 10),
                                              ],
                                          ),
                                        ),
                                        Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(total.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                                              Text("TOTAL", style: TextStyle(fontSize: 8, color: subtextColor)),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _usageRow(context, const Color(0xff3B82F6), "Patients", patients.toString()),
                                        const SizedBox(height: 12),
                                        _usageRow(context, const Color(0xff22C55E), "Doctors", doctors.toString()),
                                        const SizedBox(height: 12),
                                        _usageRow(context, const Color(0xffA855F7), "AI Calls", aiCalls.toString()),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // SYSTEM PERFORMANCE
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: shadowColor,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "SYSTEM PERFORMANCE",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: headingColor),
                              ),
                              const SizedBox(height: 20),
                              
                              // Server Uptime
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Server Uptime", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDarkAccent)),
                                  const Text("99.9%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff16A34A))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: 0.999,
                                backgroundColor: progressTrackBg,
                                color: const Color(0xff22C55E),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),

                              const SizedBox(height: 20),

                              // API Response Time
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("API Response Time", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDarkAccent)),
                                  const Text("120ms", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff3B82F6))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: 0.3,
                                backgroundColor: progressTrackBg,
                                color: const Color(0xff3B82F6),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                }
              );
            }
          );
        }
      ),
    );
  }

  Widget _legendItem(BuildContext context, Color color, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: subtextColor),
        )
      ],
    );
  }

  Widget _usageRow(BuildContext context, Color color, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final labelColor = isDark ? Colors.grey[300]! : const Color(0xff475569);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 12, color: labelColor, fontWeight: FontWeight.w600)),
          ],
        ),
        Text(value, style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
