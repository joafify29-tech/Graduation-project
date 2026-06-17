import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'patient_mood_success_screen.dart';

class PatientMoodScreen extends StatefulWidget {
  const PatientMoodScreen({super.key});

  @override
  State<PatientMoodScreen> createState() => _PatientMoodScreenState();
}

class _PatientMoodScreenState extends State<PatientMoodScreen> {
  int selectedMood = 4;

  final TextEditingController notesController =
      TextEditingController();

  final List<Map<String, dynamic>> moods = [
    {
      "emoji": Icons.sentiment_very_dissatisfied,
      "label": "VERY SAD",
      "level": 1,
    },
    {
      "emoji": Icons.sentiment_dissatisfied,
      "label": "SAD",
      "level": 2,
    },
    {
      "emoji": Icons.sentiment_neutral,
      "label": "NEUTRAL",
      "level": 3,
    },
    {
      "emoji": Icons.sentiment_satisfied_alt,
      "label": "HAPPY",
      "level": 4,
    },
    {
      "emoji": Icons.sentiment_very_satisfied,
      "label": "VERY HAPPY",
      "level": 5,
    },
  ];

Future<void> saveMood() async {
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final selectedData = moods.firstWhere(
      (e) => e['level'] == selectedMood,
    );

    final now = DateTime.now();

    // Save Mood History
    await FirebaseFirestore.instance
        .collection('mood_updates')
        .add({
      "patientUid": uid,
      "mood": selectedData['label'],
      "moodLevel": selectedMood,
      "notes": notesController.text.trim(),
      "createdAt": Timestamp.now(),
    });

    // Get all mood updates for this patient
    final moodDocs = await FirebaseFirestore.instance
        .collection('mood_updates')
        .where('patientUid', isEqualTo: uid)
        .orderBy('createdAt')
        
        .get();
    final sortedDocs = moodDocs.docs.reversed.toList();    

    int totalMoodUpdates = moodDocs.docs.length;

    // Calculate Current Streak
    int currentStreak = 0;

    DateTime checkDate = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final uniqueDays = <String>{};

    for (var doc in sortedDocs) {
      final date = (doc['createdAt'] as Timestamp)
          .toDate();

      final key =
          "${date.year}-${date.month}-${date.day}";

      uniqueDays.add(key);
    }

    while (true) {
      final key =
          "${checkDate.year}-${checkDate.month}-${checkDate.day}";

      if (uniqueDays.contains(key)) {
        currentStreak++;
        checkDate = checkDate.subtract(
          const Duration(days: 1),
        );
      } else {
        break;
      }
    }

    // Calculate Longest Streak
    List<DateTime> days = uniqueDays.map((e) {
      final parts = e.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }).toList();

    days.sort();

    int longestStreak = 0;
    int tempStreak = 1;

    if (days.isNotEmpty) {
      longestStreak = 1;
    }

    for (int i = 1; i < days.length; i++) {
      final diff =
          days[i].difference(days[i - 1]).inDays;

      if (diff == 1) {
        tempStreak++;

        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
      } else {
        tempStreak = 1;
      }
    }

    // Update Referral Data
    await FirebaseFirestore.instance
        .collection('referrals')
        .doc(uid)
        .update({
      "currentMood": selectedData['label'],
      "currentMoodLevel": selectedMood,
      "lastMoodUpdate": Timestamp.now(),
      "currentStreak": currentStreak,
      "longestStreak": longestStreak,
      "totalMoodUpdates": totalMoodUpdates,
    });

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const PatientMoodSuccessScreen(),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString(),
        ),
      ),
    );
  }
}
Widget buildMoodItem(
  Map<String, dynamic> mood,
) {
  bool isSelected =
      selectedMood == mood['level'];

  return GestureDetector(
    onTap: () {
      setState(() {
        selectedMood = mood['level'];
      });
    },
    child: Column(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? const Color(0xff2F6FED)
                  : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Icon(
            mood['emoji'],
            size: 30,
            color: isSelected
                ? const Color(0xff2F6FED)
                : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          mood['label'],
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xff2F6FED)
                : Colors.grey,
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xffF7F8FA),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: const Text(
          "Mood Check-In",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 10),

            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xffE8F0FF),
                borderRadius:
                    BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 35,
                color: Color(0xff2F6FED),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "How are you feeling today?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Take a moment to check in with yourself.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 35),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: moods
                  .map(
                    (mood) =>
                        buildMoodItem(mood),
                  )
                  .toList(),
            ),

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Add optional notes",
                style: TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    "What's on your mind?",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          16),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    const Color(0xffEEF4FF),
                borderRadius:
                    BorderRadius.circular(
                        16),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: const [
                  Icon(
                    Icons.lightbulb_outline,
                    color:
                        Color(0xff2F6FED),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Tracking your mood helps identify triggers and supports your recovery journey.",
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: saveMood,
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
                                30),
                  ),
                ),
                child: const Text(
                  "Submit Update",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}