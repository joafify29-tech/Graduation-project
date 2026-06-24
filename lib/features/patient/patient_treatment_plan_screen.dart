import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_doctor_chat_screen.dart';
import 'medication_details_screen.dart';

class PatientTreatmentPlanScreen extends StatelessWidget {
  const PatientTreatmentPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: textColor,
        ),
        title: Text(
          "Treatment Plan",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot>(
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

          if (data == null) {
            return Center(
              child: Text(
                "Patient data not found",
                style: TextStyle(color: textColor),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                buildDoctorCard(
                  context,
                  data['doctorName'] ?? 'Doctor',
                  data['doctorSpecialization'] ?? '',
                ),

                const SizedBox(height: 25),

                Text(
                  "Prescribed Medications",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 15),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('referrals')
                      .doc(uid)
                      .collection('medications')
                      .where(
                        'isActive',
                        isEqualTo: true,
                      )
                      .snapshots(),
                  builder: (context, medsSnapshot) {

                    if (!medsSnapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final meds =
                        medsSnapshot.data!.docs;

                    if (meds.isEmpty) {
                      return Text(
                        "No medications assigned",
                        style: TextStyle(color: subtextColor),
                      );
                    }

                    return Column(
                      children: meds.map((doc) {

                        final med =
                            doc.data()
                                as Map<String, dynamic>;

                        return buildMedicationCard(
                          context,
                          med,
                        );

                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 30),

                Text(
                  "Latest Message",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 15),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('referrals')
                      .doc(uid)
                      .collection('messages')
                      .orderBy(
                        'createdAt',
                        descending: true,
                      )
                      .limit(1)
                      .snapshots(),
                  builder: (context, msgSnapshot) {

                    if (!msgSnapshot.hasData) {
                      return const SizedBox();
                    }

                    if (msgSnapshot.data!.docs.isEmpty) {
                      return buildMessageCard(
                        context,
                        "No messages yet",
                      );
                    }

                    final message =
                        msgSnapshot.data!.docs.first
                            .data()
                            as Map<String, dynamic>;

                    return buildMessageCard(
                      context,
                      message['text'] ?? '',
                    );
                  },
                ),

                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xff3A2A1A) : const Color(0xffFFF7E8),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [

                      const Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          "Please follow your treatment plan and contact your doctor if you experience any issues.",
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildDoctorCard(
  BuildContext context,
  String doctorName,
  String specialization,
) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const PatientDoctorChatScreen(),
        ),
      );
    },
    borderRadius: BorderRadius.circular(24),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff2F6FED),
            Color(0xff5D8FFF),
          ],
        ),
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: Row(
        children: [

          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: Color(0xff2F6FED),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  doctorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  specialization,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chat_bubble,
            color: Colors.white,
          ),
        ],
      ),
    ),
  );
}

Widget buildMedicationCard(
  BuildContext context,
  Map<String, dynamic> med,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
  final textColor = isDark ? Colors.white : Colors.black;
  final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

  return InkWell(
    borderRadius: BorderRadius.circular(22),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MedicationDetailsScreen(
            medication: med,
          ),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [

          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xff1A2A4A) : const Color(0xffEEF4FF),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.medication_outlined,
              color: Color(0xff2F6FED),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  med['name'] ?? '',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 17,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  med['dosage'] ?? '',
                  style: TextStyle(
                    color: subtextColor,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  med['frequency'] ?? '',
                  style: const TextStyle(
                    color: Color(0xff2F6FED),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    ),
  );
}

Widget buildMessageCard(
  BuildContext context,
  String message,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
  final textColor = isDark ? Colors.white : Colors.black;

  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const PatientDoctorChatScreen(),
        ),
      );
    },
    borderRadius:
        BorderRadius.circular(20),
    child: Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        children: [

          const Icon(
            Icons.message_outlined,
            color: Color(0xff2F6FED),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              message,
              maxLines: 3,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
              ),
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios,
            size: 15,
            color: Colors.grey,
          ),
        ],
      ),
    ),
  );
}
}
