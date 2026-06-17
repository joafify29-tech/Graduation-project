import 'package:flutter/material.dart';

import 'patient_doctor_chat_screen.dart';

class MedicationDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> medication;

  const MedicationDetailsScreen({
    super.key,
    required this.medication,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF7F8FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme:
            const IconThemeData(
          color: Colors.black,
        ),
        title: const Text(
          "Medication Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [

            /// ICON

            Container(
              width: 140,
              height: 140,
              decoration:
                  const BoxDecoration(
                color:
                    Color(0xffEEF4FF),
                shape:
                    BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication_outlined,
                size: 70,
                color:
                    Color(0xff2F6FED),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              medication['name'] ??
                  '',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.white,
                borderRadius:
                    BorderRadius
                        .circular(
                            30),
              ),
              child: Text(
                medication[
                        'instructions'] ??
                    '',
                textAlign:
                    TextAlign.center,
              ),
            ),

            const SizedBox(height: 25),

            Row(
              children: [

                Expanded(
                  child:
                      actionCard(
                    Icons.alarm,
                    "Reminder",
                    const Color(
                        0xffEAF1FF),
                  ),
                ),

                const SizedBox(
                    width: 12),

                Expanded(
                  child:
                      actionCard(
                    Icons
                        .check_circle,
                    "Logged Today",
                    const Color(
                        0xffE8F8EE),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Container(
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius:
        BorderRadius.circular(20),
  ),
  child: Column(
    children: [

      infoRow(
        Icons.person_outline,
        "Prescribed By",
        "Dr. test",
      ),

      const Divider(),

      infoRow(
        Icons.calendar_today_outlined,
        "Duration",
        medication['duration'] ?? '',
      ),

      const Divider(),

      infoRow(
        Icons.monitor_weight_outlined,
        "Dosage",
        medication['dosage'] ?? '',
      ),

      const Divider(),

      infoRow(
        Icons.repeat,
        "Frequency",
        medication['frequency'] ?? '',
      ),
    ],
  ),
),

const SizedBox(height: 24),

/// MESSAGE DOCTOR CARD

InkWell(
  borderRadius:
      BorderRadius.circular(22),

  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const PatientDoctorChatScreen(),
      ),
    );
  },

  child: Container(
    padding:
        const EdgeInsets.all(20),

    decoration: BoxDecoration(
      color:
          const Color(0xffEEF4FF),
      borderRadius:
          BorderRadius.circular(22),
    ),

    child: const Row(
      children: [

        CircleAvatar(
          radius: 24,
          backgroundColor:
              Colors.white,
          child: Icon(
            Icons.chat,
            color:
                Color(0xff2F6FED),
          ),
        ),

        SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [

              Text(
                "Need help with this medication?",
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              SizedBox(height: 4),

              Text(
                "Message your doctor directly.",
              ),
            ],
          ),
        ),

        Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
      ],
    ),
  ),
),

const SizedBox(height: 20),

/// BIG BUTTON

SizedBox(
  width: double.infinity,
  height: 58,
  child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor:
          const Color(0xff2F6FED),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
                30),
      ),
    ),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const PatientDoctorChatScreen(),
        ),
      );
    },
    icon: const Icon(
      Icons.chat_bubble,
      color: Colors.white,
    ),
    label: const Text(
      "Message Doctor",
      style: TextStyle(
        color: Colors.white,
        fontWeight:
            FontWeight.bold,
      ),
    ),
  ),
),

const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }
  Widget actionCard(
  IconData icon,
  String title,
  Color color,
) {
  return Container(
    height: 120,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(20),
    ),
    child: Column(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [

        CircleAvatar(
          radius: 24,
          backgroundColor: color,
          child: Icon(
            icon,
            color:
                const Color(0xff2F6FED),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          title,
          style: const TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

Widget infoRow(
  IconData icon,
  String title,
  String value,
) {
  return Row(
    children: [

      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color:
              const Color(0xffF4F6FA),
          borderRadius:
              BorderRadius.circular(
                  12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: Colors.grey[700],
        ),
      ),

      const SizedBox(width: 12),

      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ),

      Text(
        value,
        style: const TextStyle(
          fontWeight:
              FontWeight.w600,
        ),
      ),
    ],
  );
}
}