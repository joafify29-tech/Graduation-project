import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PatientCalendarScreen extends StatefulWidget {
  const PatientCalendarScreen({super.key});

  @override
  State<PatientCalendarScreen> createState() =>
      _PatientCalendarScreenState();
}

class _PatientCalendarScreenState
    extends State<PatientCalendarScreen> {

  DateTime selectedDate = DateTime.now();

  String get selectedKey =>
      "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";

  @override
  Widget build(BuildContext context) {
    final uid =
        FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(
          child: Text("No User"),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xffF7F8FA),

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('referrals')
              .doc(uid)
              .collection('reminders')
              .orderBy('createdAt')
              .snapshots(),

          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            final reminders =
                snapshot.data!.docs;

            int completed = 0;

            for (var doc in reminders) {

              final data =
                  doc.data()
                      as Map<String, dynamic>;

              final dates =
                  List<String>.from(
                data['completedDates'] ??
                    [],
              );

              if (dates.contains(
                  selectedKey)) {
                completed++;
              }
            }

            final total =
                reminders.length;

            final progress =
                total == 0
                    ? 0.0
                    : completed / total;

            return SingleChildScrollView(
              padding:
                  const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    "Recovery Calendar",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Stay consistent every day.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 25),

                  buildWeekSelector(),

                  const SizedBox(height: 25),

                  Container(
                    padding:
                        const EdgeInsets.all(
                            22),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,
                      borderRadius:
                          BorderRadius
                              .circular(
                                  28),
                    ),

                    child: Row(
                      children: [

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [

                              const Text(
                                "TODAY'S PROGRESS",
                                style:
                                    TextStyle(
                                  color:
                                      Colors
                                          .grey,
                                ),
                              ),

                              const SizedBox(
                                  height:
                                      8),

                              Text(
                                "$completed of $total Tasks Done",
                                style:
                                    const TextStyle(
                                  fontSize:
                                      26,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              const SizedBox(
                                  height:
                                      8),

                              Text(
                                "${(progress * 100).toInt()}% Complete",
                                style:
                                    const TextStyle(
                                  color: Color(
                                      0xff34C759),
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          width: 90,
                          height: 90,

                          child:
                              CircularProgressIndicator(
                            value:
                                progress,
                            strokeWidth:
                                8,
                            color:
                                const Color(
                                    0xff2F6FED),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Daily Plan",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),
                                    if (reminders.isEmpty)

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(
                              20),
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,
                        borderRadius:
                            BorderRadius
                                .circular(
                                    24),
                      ),
                      child: const Text(
                        "No reminders available",
                      ),
                    ),

                  ...reminders.map(
                    (doc) {

                      final data =
                          doc.data()
                              as Map<String,
                                  dynamic>;

                      final dates =
                          List<String>.from(
                        data['completedDates'] ??
                            [],
                      );

                      final isDone =
                          dates.contains(
                              selectedKey);

                      return reminderCard(
                        uid,
                        doc.id,
                        data,
                        isDone,
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildWeekSelector() {

    final now = DateTime.now();

    final start =
        now.subtract(
      Duration(
        days: now.weekday - 1,
      ),
    );

    return Row(
      mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,
      children: List.generate(
        7,
        (index) {

          final day =
              start.add(
            Duration(
              days: index,
            ),
          );

          final selected =
              day.day ==
                      selectedDate.day &&
                  day.month ==
                      selectedDate.month &&
                  day.year ==
                      selectedDate.year;

          const names = [
            "M",
            "T",
            "W",
            "T",
            "F",
            "S",
            "S"
          ];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate =
                    day;
              });
            },
            child: Container(
              width: 45,
              height: 70,
              decoration:
                  BoxDecoration(
                color: selected
                    ? const Color(
                        0xff2F6FED)
                    : Colors.white,
                borderRadius:
                    BorderRadius
                        .circular(
                            18),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [

                  Text(
                    names[index],
                    style:
                        TextStyle(
                      color: selected
                          ? Colors.white
                          : Colors
                              .grey,
                    ),
                  ),

                  const SizedBox(
                      height: 5),

                  Text(
                    day.day
                        .toString(),
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight
                              .bold,
                      color: selected
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget reminderCard(
    String uid,
    String reminderId,
    Map<String, dynamic> data,
    bool isDone,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
              bottom: 12),
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
                22),
      ),
      child: Row(
        children: [

          GestureDetector(
            onTap: () async {

              final ref =
                  FirebaseFirestore
                      .instance
                      .collection(
                          'referrals')
                      .doc(uid)
                      .collection(
                          'reminders')
                      .doc(
                          reminderId);

              final snap =
                  await ref.get();

              final map =
                  snap.data() ?? {};

              List<String>
                  dates =
                  List<String>.from(
                map['completedDates'] ??
                    [],
              );

              if (dates.contains(
                  selectedKey)) {

                dates.remove(
                    selectedKey);

              } else {

                dates.add(
                    selectedKey);
              }

              await ref.update({
                'completedDates':
                    dates,
              });
            },

            child: Icon(
              isDone
                  ? Icons
                      .check_circle
                  : Icons
                      .radio_button_unchecked,
              color: isDone
                  ? const Color(
                      0xff34C759)
                  : Colors.grey,
              size: 32,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [

                Text(
                  data['title'] ?? '',
                  style:
                      TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight
                            .bold,
                    decoration:
                        isDone
                            ? TextDecoration
                                .lineThrough
                            : null,
                  ),
                ),

                const SizedBox(
                    height: 4),

                Text(
                  "${data['time']} • ${data['frequency']}",
                  style:
                      const TextStyle(
                    color:
                        Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration:
                BoxDecoration(
              color: isDone
                  ? const Color(
                      0xffE8F8EE)
                  : const Color(
                      0xffFFF2E5),
              borderRadius:
                  BorderRadius
                      .circular(20),
            ),
            child: Text(
              isDone
                  ? "DONE"
                  : "PENDING",
              style:
                  TextStyle(
                color: isDone
                    ? const Color(
                        0xff34C759)
                    : Colors.orange,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}