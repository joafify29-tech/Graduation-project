import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/time_service.dart';

class PatientMoodSuccessScreen extends StatelessWidget {
  const PatientMoodSuccessScreen({super.key});

  Future<int> getRecoveryDays() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('referrals')
        .doc(uid)
        .get();

    if (!doc.exists) return 0;

    final Timestamp createdAt =
        doc['createdAt'];

    final startDate =
        createdAt.toDate();

    final days = TimeService.now()
        .difference(startDate)
        .inDays;

    return days <= 0 ? 1 : days;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      backgroundColor: bg,

      body: SafeArea(
        child: FutureBuilder<int>(
          future: getRecoveryDays(),
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            final streak = snapshot.data!;

            return Padding(
              padding:
                  const EdgeInsets.all(20),
              child: Column(
                children: [

                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(
                              context);
                        },
                        icon: Icon(
                            Icons.close,
                            color: textColor),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 30),

                  Container(
                    width: 100,
                    height: 100,
                    decoration:
                        BoxDecoration(
                      color: isDark ? const Color(0xff1A2A4A) : const Color(0xffE8F0FF),
                      borderRadius:
                          BorderRadius
                              .circular(
                                  50),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 55,
                      color: Color(
                          0xff2F6FED),
                    ),
                  ),

                  const SizedBox(
                      height: 25),

                  Text(
                    "Update\nSubmitted!",
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight:
                          FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  Text(
                    "Your progress has been recorded.\nEvery check-in is a step forward in your recovery journey.",
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: subtextColor,
                    ),
                  ),

                  const SizedBox(
                      height: 40),

                  Container(
                    padding:
                        const EdgeInsets
                            .all(22),
                    decoration:
                        BoxDecoration(
                      color: cardBg,
                      borderRadius:
                          BorderRadius
                              .circular(
                                  22),
                      boxShadow: [
                        BoxShadow(
                          color: isDark 
                              ? Colors.black26 
                              : Colors.grey.withValues(alpha: 0.08),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [

                        Text(
                          "CONSISTENCY IS KEY",
                          style:
                              TextStyle(
                            fontSize: 12,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(
                            height: 12),

                        Text(
                          "$streak Day Streak",
                          style:
                              const TextStyle(
                            fontSize: 36,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color: Color(
                                0xff34C759),
                          ),
                        ),

                        const SizedBox(
                            height: 10),

                        Text(
                          "You're doing better than 85% of users this week.",
                          textAlign:
                              TextAlign.center,
                          style:
                              TextStyle(
                            color: subtextColor,
                            fontSize:
                                12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 55,
                    child:
                        ElevatedButton(
                      onPressed: () {

                        Navigator.popUntil(
                          context,
                          (route) =>
                              route.isFirst,
                        );
                      },
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                                0xff2F6FED),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  30),
                        ),
                      ),
                      child: const Text(
                        "Back to Dashboard",
                        style:
                            TextStyle(
                          color: Colors
                              .white,
                        ),
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {

                      // Progress Screen Later

                    },
                    child: const Text(
                      "View Progress Trends",
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}