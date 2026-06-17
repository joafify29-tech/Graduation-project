import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_mood_screen.dart';
import 'patient_treatment_plan_screen.dart';
import 'patient_ai_chat_screen.dart';
import 'patient_calendar_screen.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      body: SafeArea(
        child: uid == null
            ? const Center(child: Text("No User"))
            : StreamBuilder<DocumentSnapshot>(
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
                      snapshot.data!.data() as Map<String, dynamic>?;

                  final name =
                      data?['name'] ?? "Patient";

                  final currentMood =
                      data?['currentMood'] ??
                          "Not Updated";

                  final currentMoodLevel =
                      data?['currentMoodLevel'] ?? 0;
                      final Timestamp? createdAt =
    data?['createdAt'];

int recoveryDays = 0;

if (createdAt != null) {
  recoveryDays = DateTime.now()
      .difference(createdAt.toDate())
      .inDays;
}

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    "Good morning, $name",
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
                                    "You're doing great today.",
                                    style: TextStyle(
                                      color:
                                          Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons
                                  .notifications_none,
                              color: Color(
                                  0xff2F6FED),
                            ),
                          ],
                        ),

                        const SizedBox(
                            height: 20),

                        // Recovery Card
                        Container(
                          padding:
                              const EdgeInsets
                                  .all(18),
                          decoration:
                              BoxDecoration(
                            color: const Color(
                                0xffDFF3E7),
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        20),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    Color(
                                        0xff34C759),
                                child: Icon(
                                  Icons
                                      .location_on,
                                  color: Colors
                                      .white,
                                ),
                              ),
                              SizedBox(
                                  width: 12),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
  "$recoveryDays Days in Recovery",
  style: const TextStyle(
    fontWeight: FontWeight.bold,
  ),
),
                                  Text(
                                    "Keep going, one day at a time.",
                                    style:
                                        TextStyle(
                                      fontSize:
                                          12,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),

                        const SizedBox(
                            height: 20),

                        // Mood Card
                        Container(
                          padding:
                              const EdgeInsets
                                  .all(18),
                          decoration:
                              BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        20),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 25,
                                backgroundColor:
                                    Color(
                                        0xffE8F0FE),
                                child: Icon(
                                  Icons
                                      .sentiment_satisfied_alt,
                                  color: Color(
                                      0xff2F6FED),
                                ),
                              ),
                              const SizedBox(
                                  width: 12),
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
                                            5),
                                    Text(
                                      currentMood,
                                      style:
                                          const TextStyle(
                                        fontSize:
                                            18,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: const Color(
                                      0xffEEF4FF),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              20),
                                ),
                                child: Text(
                                  "$currentMoodLevel/5",
                                  style:
                                      const TextStyle(
                                    color: Color(
                                        0xff2F6FED),
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                            height: 20),

                        // Progress Card
                        // Progress Card
Container(
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
  ),
  child: Row(
    mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
    children: [
      const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S PROGRESS",
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "2 of 4 Tasks Done",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(
          value: .45,
          strokeWidth: 6,
          color: Color(0xff2F6FED),
        ),
      ),
    ],
  ),
),

const SizedBox(height: 25),

Row(
  mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
  children: [

    const Text(
      "Today's Reminders",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    GestureDetector(
      onTap: () {

        Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) =>
        const PatientCalendarScreen(),
  ),
);

      },
      child: const Text(
        "See All",
        style: TextStyle(
          color: Color(0xff2F6FED),
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ],
),

const SizedBox(height: 15),

StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('referrals')
      .doc(uid)
      .collection('reminders')
      .snapshots(),
  builder: (context, reminderSnapshot) {

    if (!reminderSnapshot.hasData) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final reminders =
        reminderSnapshot.data!.docs;

    if (reminders.isEmpty) {
      return Container(
        padding:
            const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: const Row(
          children: [

            Icon(
              Icons.notifications_off,
              color: Colors.grey,
            ),

            SizedBox(width: 12),

            Text(
              "No reminders today",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: reminders.take(3).map((doc) {

        final reminder =
            doc.data()
                as Map<String, dynamic>;

        return reminderCard(
          title:
              reminder['title'] ?? '',
          subtitle:
              "${reminder['time'] ?? ''} • ${reminder['frequency'] ?? ''}",
        );

      }).toList(),
    );
  },
),

const SizedBox(height: 25),

const Text(
  "Resources",
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

GridView.count(
  shrinkWrap: true,
  physics:
      const NeverScrollableScrollPhysics(),
  crossAxisCount: 2,
  mainAxisSpacing: 12,
  crossAxisSpacing: 12,
  childAspectRatio: 1,
  children: [

    resourceCard(
      context,
      "Update Mood",
      Icons.sentiment_satisfied_alt,
      const Color(0xffFFE9D6),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const PatientMoodScreen(),
          ),
        );
      },
    ),

    resourceCard(
  context,
  "AI Chat",
  Icons.smart_toy,
  const Color(0xff2F6FED),
  white: true,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const PatientAiChatScreen(),
      ),
    );
  },
),

    resourceCard(
  context,
  "Treatment Plan",
  Icons.description,
  const Color(0xffE8F0FE),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const PatientTreatmentPlanScreen(),
      ),
    );
  },
),
    resourceCard(
      context,
      "My Sessions",
      Icons.event_note,
      const Color(0xffF3E8FF),
    ),
  ],
),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget reminderCard({
    required String title,
    required String subtitle,
    bool done = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            done
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            color: done ? Colors.blue : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration:
                        done ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.notifications_none),
        ],
      ),
    );
  }

  Widget resourceCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color, {
    bool white = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius:
              BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor:
                  Colors.white24,
              child: Icon(
                icon,
                color: white
                    ? Colors.white
                    : Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: white
                    ? Colors.white
                    : Colors.black,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}