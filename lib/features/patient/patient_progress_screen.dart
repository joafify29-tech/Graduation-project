import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_calendar_screen.dart';

class PatientProgressScreen extends StatelessWidget {
  const PatientProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(
          child: Text("No User"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
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
                              CrossAxisAlignment
                                  .start,
                          children: [

                            Text(
                              "Hello, $name 👋",
                              style:
                                  const TextStyle(
                                fontSize: 28,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                                height: 5),

                            const Text(
                              "Track your recovery progress and achievements.",
                              style: TextStyle(
                                color:
                                    Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            Color(
                                0xffE8F0FF),
                        child: Icon(
                          Icons.person,
                          color: Color(
                              0xff2F6FED),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// RECOVERY OVERVIEW

                  Container(
                    padding:
                        const EdgeInsets.all(
                            24),
                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius
                              .circular(
                                  28),
                    ),
                    child: Column(
                      children: [

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [

                            const Text(
                              "Recovery Journey",
                              style:
                                  TextStyle(
                                fontSize:
                                    20,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    12,
                                vertical:
                                    6,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                        0xffE8F8EE),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            20),
                              ),
                              child:
                                  const Text(
                                "ACTIVE",
                                style:
                                    TextStyle(
                                  color: Color(
                                      0xff34C759),
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                            height: 25),

                        Container(
                          width: 150,
                          height: 150,
                          decoration:
                              BoxDecoration(
                            shape: BoxShape
                                .circle,
                            border:
                                Border.all(
                              color:
                                  const Color(
                                      0xff34C759),
                              width: 8,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [

                                Text(
                                  "$recoveryDays",
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        42,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                const Text(
                                  "DAYS",
                                  style:
                                      TextStyle(
                                    color: Colors
                                        .grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(
                            height: 20),

                        Text(
                          "$recoveryDays Days In Recovery",
                          style:
                              const TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                            height: 8),

                        const Text(
                          "Every day counts. Keep moving forward.",
                          style:
                              TextStyle(
                            color:
                                Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// CURRENT MOOD

                  Container(
                    padding:
                        const EdgeInsets.all(
                            20),
                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius
                              .circular(
                                  24),
                    ),
                    child: Row(
                      children: [

                        const CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              Color(
                                  0xffFFE9D6),
                          child: Text(
                            "😊",
                            style:
                                TextStyle(
                              fontSize:
                                  26,
                            ),
                          ),
                        ),

                        const SizedBox(
                            width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [

                              const Text(
                                "Current Mood",
                                style:
                                    TextStyle(
                                  color: Colors
                                      .grey,
                                ),
                              ),

                              const SizedBox(
                                  height:
                                      4),

                              Text(
                                currentMood,
                                style:
                                    const TextStyle(
                                  fontSize:
                                      22,
                                  fontWeight:
                                      FontWeight
                                          .bold,
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

                  const Text(
                    "Recovery Statistics",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),
                  GridView.count(
  shrinkWrap: true,
  physics:
      const NeverScrollableScrollPhysics(),
  crossAxisCount: 2,
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
  childAspectRatio: 1.0,
  children: [

    statCard(
      title: "Recovery Days",
      value: "$recoveryDays",
      icon: Icons.favorite,
      color: const Color(0xffE8F8EE),
    ),

    statCard(
      title: "Current Streak",
      value: "$currentStreak",
      icon: Icons.local_fire_department,
      color: const Color(0xffFFF2E5),
    ),

    statCard(
      title: "Longest Streak",
      value: "$longestStreak",
      icon: Icons.emoji_events,
      color: const Color(0xffFFF7D6),
    ),

    statCard(
      title: "Check-ins",
      value: "$totalMoodUpdates",
      icon: Icons.check_circle,
      color: const Color(0xffE8F0FF),
    ),
  ],
),

const SizedBox(height: 30),

/// MOOD ANALYTICS

const Text(
  "Mood Analytics",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
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
            days[
                i % days.length],
            moodLevel.toDouble(),
          ),
        );
      }

      return Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          const Text(
            "Recent Activity",
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceEvenly,
            children: bars,
          ),

          const SizedBox(height: 15),

          Text(
            "${docs.length} total mood updates",
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      );
    },
  ),
),
const SizedBox(height: 30),

const Text(
  "Milestones & Badges",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

GridView.count(
  shrinkWrap: true,
  physics:
      const NeverScrollableScrollPhysics(),
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
    color: const Color(0xffE8F8EE),
    borderRadius:
        BorderRadius.circular(20),
  ),
  child: const Row(
    children: [

      Icon(
        Icons.format_quote,
        color: Color(0xff34C759),
      ),

      SizedBox(width: 10),

      Expanded(
        child: Text(
          "Every step you take today is a seed for a brighter tomorrow.",
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
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          const PatientCalendarScreen(),
    ),
  );
},
    style:
        ElevatedButton.styleFrom(
      backgroundColor:
          const Color(0xff34C759),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
                30),
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


const SizedBox(height: 30),                ],
              ),
            );
          },
        ),
      ),
    );
  }
Widget moodBar(
  String day,
  double value,
) {
  return Column(
    children: [

      Container(
        width: 22,
        height: value * 22,
        decoration: BoxDecoration(
          color:
              const Color(0xff34C759),
          borderRadius:
              BorderRadius.circular(8),
        ),
      ),

      const SizedBox(height: 8),

      Text(day),
    ],
  );
}

Widget buildBadge(
  BuildContext context, {
  required String title,
  required IconData icon,
  required bool unlocked,
}) {
  return GestureDetector(
    onTap: () {
      showDialog(
        context: context,
        builder: (_) {
          return Dialog(
  shape: RoundedRectangleBorder(
    borderRadius:
        BorderRadius.circular(30),
  ),
  child: Container(
    padding:
        const EdgeInsets.all(25),
    child: Column(
      mainAxisSize:
          MainAxisSize.min,
      children: [

        CircleAvatar(
          radius: 45,
          backgroundColor:
              unlocked
                  ? const Color(
                      0xff34C759)
                  : Colors.grey
                      .shade300,
          child: Icon(
            icon,
            size: 40,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          title,
          style:
              const TextStyle(
            fontSize: 28,
            fontWeight:
                FontWeight.bold,
          ),
          textAlign:
              TextAlign.center,
        ),

        const SizedBox(height: 10),

        Text(
          unlocked
              ? "Achievement Unlocked!"
              : "Locked Milestone",
          style: TextStyle(
            color: unlocked
                ? const Color(
                    0xff34C759)
                : Colors.orange,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        LinearProgressIndicator(
          value: unlocked
              ? 1
              : 0.4,
          minHeight: 10,
          borderRadius:
              BorderRadius.circular(
                  20),
        ),

        const SizedBox(height: 15),

        Text(
          unlocked
              ? "Great job! Keep pushing forward."
              : "Keep checking in to unlock this achievement.",
          textAlign:
              TextAlign.center,
        ),

        const SizedBox(height: 25),

        SizedBox(
          width:
              double.infinity,
          height: 50,
          child:
              ElevatedButton(
            onPressed: () {
              Navigator.pop(
                  context);
            },
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(
                      0xff2F6FED),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                            25),
              ),
            ),
            child:
                const Text(
              "Close",
              style:
                  TextStyle(
                color:
                    Colors.white,
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
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
                22),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [

          CircleAvatar(
            radius: 28,
            backgroundColor:
                unlocked
                    ? const Color(
                        0xffE8F8EE)
                    : Colors.grey
                        .shade200,
            child: Icon(
              icon,
              color: unlocked
                  ? const Color(
                      0xff34C759)
                  : Colors.grey,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
