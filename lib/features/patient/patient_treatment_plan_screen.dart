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

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: const Text(
          "Treatment Plan",
          style: TextStyle(
            color: Colors.black,
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
            return const Center(
              child: Text(
                "Patient data not found",
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

                const Text(
                  "Prescribed Medications",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
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
      return const Text(
        "No medications assigned",
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

const Text(
  "Latest Message",
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
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
    color: const Color(0xffFFF7E8),
    borderRadius:
        BorderRadius.circular(20),
  ),
  child: const Row(
    children: [

      Icon(
        Icons.info_outline,
        color: Colors.orange,
      ),

      SizedBox(width: 12),

      Expanded(
        child: Text(
          "Please follow your treatment plan and contact your doctor if you experience any issues.",
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
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
              color: const Color(0xffEEF4FF),
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
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 17,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  med['dosage'] ?? '',
                  style: const TextStyle(
                    color: Colors.grey,
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
        color: Colors.white,
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
