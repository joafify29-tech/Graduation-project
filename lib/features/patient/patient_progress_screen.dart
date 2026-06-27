import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_calendar_screen.dart';
import 'patient_main_screen.dart';
import 'patient_home_screen.dart';

class PatientProgressScreen extends StatelessWidget {
  const PatientProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    if (uid == null) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Text("No User", style: TextStyle(color: textColor)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('referrals')
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final data =
                snapshot.data!.data()
                    as Map<String, dynamic>?;

            final name =
                data?['name'] ?? "Patient";

            final currentMood =
                data?['currentMood'] ??
                    "UNKNOWN";
                    
            final currentMoodLevel =
                data?['currentMoodLevel'] ?? 0;

            final currentStreak =
                data?['currentStreak'] ?? 0;

            final longestStreak =
                data?['longestStreak'] ?? 0;

            final totalMoodUpdates =
                data?['totalMoodUpdates'] ?? 0;

            final createdAt =
                data?['createdAt']
                    as Timestamp?;

            final recoveryDays =
                createdAt == null
                    ? 0
                    : DateTime.now()
                            .difference(
                              createdAt.toDate(),
                            )
                            .inDays +
                        1;

            return SingleChildScrollView(
              padding:
                  const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  /// HEADER

                  Row(
                    children: [

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Text(
                              "Hello, $name 👋",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "Track your recovery progress and achievements.",
                              style: TextStyle(
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      CircleAvatar(
                        radius: 24,
                        backgroundColor: isDark ? const Color(0xff1E2A3A) : const Color(0xffE8F0FF),
                        child: Icon(
                          Icons.person,
                          color: isDark ? Colors.blue.shade200 : const Color(0xff2F6FED),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// RECOVERY OVERVIEW

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      children: [

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [

                            Text(
                              "Recovery Journey",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xff1A3B2B) : const Color(0xffE8F8EE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "ACTIVE",
                                style: TextStyle(
                                  color: Color(0xff34C759),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xff34C759),
                              width: 8,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [

                                Text(
                                  "$recoveryDays",
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),

                                Text(
                                  "DAYS",
                                  style: TextStyle(
                                    color: subtextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "$recoveryDays Days In Recovery",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Every day counts. Keep moving forward.",
                          style: TextStyle(
                            color: subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// CURRENT MOOD

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [

                        CircleAvatar(
                          radius: 28,
                          backgroundColor: isDark ? const Color(0xff3A2A1A) : const Color(0xffFFE9D6),
                          child: Icon(
                            getMoodIcon(currentMoodLevel),
                            color: Colors.orange,
                            size: 26,
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              Text(
                                "Current Mood",
                                style: TextStyle(
                                  color: subtextColor,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                currentMood,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// STATISTICS

                  Text(
                    "Recovery Statistics",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                    children: [

                      statCard(
                        context,
                        title: "Recovery Days",
                        value: "$recoveryDays",
                        icon: Icons.favorite,
                        color: isDark ? const Color(0xff1A3B2B) : const Color(0xffE8F8EE),
                      ),

                      statCard(
                        context,
                        title: "Current Streak",
                        value: "$currentStreak",
                        icon: Icons.local_fire_department,
                        color: isDark ? const Color(0xff3A2A1A) : const Color(0xffFFF2E5),
                      ),

                      statCard(
                        context,
                        title: "Longest Streak",
                        value: "$longestStreak",
                        icon: Icons.emoji_events,
                        color: isDark ? const Color(0xff3A3A1A) : const Color(0xffFFF7D6),
                      ),

                      statCard(
                        context,
                        title: "Check-ins",
                        value: "$totalMoodUpdates",
                        icon: Icons.check_circle,
                        color: isDark ? const Color(0xff1A2A4A) : const Color(0xffE8F0FF),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// MOOD ANALYTICS

                  Text(
                    "Mood Analytics",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('mood_updates')
                          .where(
                            'patientUid',
                            isEqualTo: uid,
                          )
                          .orderBy('createdAt')
                          .snapshots(),
                      builder: (context, moodSnapshot) {

                        if (!moodSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final docs =
                            moodSnapshot.data!.docs;

                        final recentDocs =
                            docs.reversed.take(7).toList();

                        List<Widget> bars = [];

                        const days = [
                          "M",
                          "T",
                          "W",
                          "T",
                          "F",
                          "S",
                          "S"
                        ];

                        for (int i = 0;
                            i < recentDocs.length;
                            i++) {

                          final moodLevel =
                              recentDocs[i]
                                      ['moodLevel']
                                  as int;

                          bars.add(
                            moodBar(
                              context,
                              days[i % days.length],
                              moodLevel.toDouble(),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Text(
                              "Recent Activity",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: bars,
                            ),

                            const SizedBox(height: 15),

                            Text(
                              "${docs.length} total mood updates",
                              style: TextStyle(
                                color: subtextColor,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  Text(
                    "Milestones & Badges",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 15),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                    children: [

                      buildBadge(
                        context,
                        title: "7 Day Streak",
                        icon: Icons.verified,
                        unlocked:
                            currentStreak >= 7,
                      ),

                      buildBadge(
                        context,
                        title: "First Session",
                        icon: Icons.assignment_turned_in,
                        unlocked:
                            totalMoodUpdates >= 1,
                      ),

                      buildBadge(
                        context,
                        title: "30 Day Hero",
                        icon: Icons.lock,
                        unlocked:
                            currentStreak >= 30,
                      ),

                      buildBadge(
                        context,
                        title: "Growth Mindset",
                        icon: Icons.psychology,
                        unlocked:
                            totalMoodUpdates >= 14,
                      ),

                      buildBadge(
                        context,
                        title: "Mastery",
                        icon: Icons.emoji_events,
                        unlocked:
                            currentStreak >= 60,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xff1A3B2B) : const Color(0xffE8F8EE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [

                        const Icon(
                          Icons.format_quote,
                          color: Color(0xff34C759),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            "Every step you take today is a seed for a brighter tomorrow.",
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        PatientMainScreen.of(context)?.changeTab(3);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff34C759),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "View Calendar",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget moodBar(
    BuildContext context,
    String day,
    double value,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Column(
      children: [

        Container(
          width: 22,
          height: value * 22,
          decoration: BoxDecoration(
            color: const Color(0xff34C759),
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        const SizedBox(height: 8),

        Text(day, style: TextStyle(color: textColor)),
      ],
    );
  }

  Widget buildBadge(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool unlocked,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) {
            return Dialog(
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Container(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    CircleAvatar(
                      radius: 45,
                      backgroundColor: unlocked
                          ? const Color(0xff34C759)
                          : (isDark ? Colors.grey[800] : Colors.grey.shade300),
                      child: Icon(
                        icon,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      unlocked
                          ? "Achievement Unlocked!"
                          : "Locked Milestone",
                      style: TextStyle(
                        color: unlocked
                            ? const Color(0xff34C759)
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    LinearProgressIndicator(
                      value: unlocked ? 1 : 0.4,
                      minHeight: 10,
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff34C759)),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      unlocked
                          ? "Great job! Keep pushing forward."
                          : "Keep checking in to unlock this achievement.",
                      style: TextStyle(color: textColor),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2F6FED),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          "Close",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            CircleAvatar(
              radius: 28,
              backgroundColor: unlocked
                  ? const Color(0xffE8F8EE)
                  : (isDark ? Colors.grey[800] : Colors.grey.shade200),
              child: Icon(
                icon,
                color: unlocked
                    ? const Color(0xff34C759)
                    : Colors.grey,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget statCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: isDark ? Colors.white : Colors.black87),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: subtextColor,
            ),
          ),
        ],
      ),
    );
  }
}
