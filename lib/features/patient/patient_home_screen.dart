import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_mood_screen.dart';
import 'patient_treatment_plan_screen.dart';
import 'patient_chat_list_screen.dart';
import 'patient_calendar_screen.dart';
import 'patient_main_screen.dart';
import '../../services/time_service.dart';

IconData getMoodIcon(int level) {
  switch (level) {
    case 1: return Icons.sentiment_very_dissatisfied;
    case 2: return Icons.sentiment_dissatisfied;
    case 3: return Icons.sentiment_neutral;
    case 4: return Icons.sentiment_satisfied_alt;
    case 5: return Icons.sentiment_very_satisfied;
    default: return Icons.sentiment_satisfied_alt;
  }
}

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: uid == null
            ? Center(child: Text("No User", style: TextStyle(color: textColor)))
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
                    recoveryDays = TimeService.now()
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
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Good morning, $name",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "You're doing great today.",
                                    style: TextStyle(
                                      color: subtextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.notifications_none,
                              color: isDark ? Colors.white70 : const Color(0xff2F6FED),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Recovery Card
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xff1B3B2B) : const Color(0xffDFF3E7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Color(0xff34C759),
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "$recoveryDays Days in Recovery",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "Keep going, one day at a time.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white70 : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Mood Card
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: isDark ? const Color(0xff1A2A4A) : const Color(0xffE8F0FE),
                                child: Icon(
                                  getMoodIcon(currentMoodLevel),
                                  color: const Color(0xff2F6FED),
                                ),
                              ),
                              const SizedBox(width: 12),
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
                                    const SizedBox(height: 5),
                                    Text(
                                      currentMood,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xff1A2A4A) : const Color(0xffEEF4FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "$currentMoodLevel/5",
                                  style: const TextStyle(
                                    color: Color(0xff2F6FED),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Progress Card
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "TODAY'S PROGRESS",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: subtextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "2 of 4 Tasks Done",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
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
                            Text(
                              "Today's Reminders",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                PatientMainScreen.of(context)?.changeTab(3);
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
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.notifications_off,
                                      color: subtextColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "No reminders today",
                                      style: TextStyle(
                                        color: subtextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              children: reminders.take(3).map((doc) {
                                final reminder =
                                    doc.data() as Map<String, dynamic>;

                                final dates = List<String>.from(reminder['completedDates'] ?? []);
                                final now = TimeService.now();
                                final todayKey = "${now.year}-${now.month}-${now.day}";
                                final isDone = dates.contains(todayKey);

                                return reminderCard(
                                  context: context,
                                  title: reminder['title'] ?? '',
                                  subtitle: "${reminder['time'] ?? ''} • ${reminder['frequency'] ?? ''}",
                                  done: isDone,
                                  onTap: () {
                                    if (isDone) {
                                      dates.remove(todayKey);
                                    } else {
                                      dates.add(todayKey);
                                    }
                                    FirebaseFirestore.instance
                                        .collection('referrals')
                                        .doc(uid)
                                        .collection('reminders')
                                        .doc(doc.id)
                                        .update({'completedDates': dates});
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),

                        const SizedBox(height: 25),

                        Text(
                          "Resources",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 15),

                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1,
                          children: [
                            resourceCard(
                              context,
                              "Update Mood",
                              getMoodIcon(currentMoodLevel),
                              isDark ? const Color(0xff3A2A1A) : const Color(0xffFFE9D6),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PatientMoodScreen(),
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
                                    builder: (_) => const PatientChatListScreen(),
                                  ),
                                );
                              },
                            ),
                            resourceCard(
                              context,
                              "Treatment Plan",
                              Icons.description,
                              isDark ? const Color(0xff1A2A4A) : const Color(0xffE8F0FE),
                              iconColor: isDark ? Colors.blue.shade300 : Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PatientTreatmentPlanScreen(),
                                  ),
                                );
                              },
                            ),
                            resourceCard(
                              context,
                              "My Sessions",
                              Icons.event_note,
                              isDark ? const Color(0xff2A1A3A) : const Color(0xffF3E8FF),
                              iconColor: isDark ? Colors.purple.shade300 : Colors.purple,
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
    required BuildContext context,
    required String title,
    required String subtitle,
    bool done = false,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: done ? Colors.green : (isDark ? Colors.grey[600] : Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: done 
                    ? (isDark ? const Color(0xff1A3B2B) : const Color(0xffDFF3E7))
                    : (isDark ? const Color(0xff3A2A1A) : const Color(0xffFFF2E5)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                done ? "DONE" : "PENDING",
                style: TextStyle(
                  color: done ? Colors.green : Colors.orange, 
                  fontSize: 10, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
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
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(
                icon,
                color: white
                    ? Colors.white
                    : (iconColor ?? (isDark ? Colors.orange.shade300 : Colors.orange)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: white ? Colors.white : textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}