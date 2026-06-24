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
          "Medication Details",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
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
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff1A2A4A) : const Color(0xffEEF4FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication_outlined,
                size: 70,
                color: Color(0xff2F6FED),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              medication['name'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                medication['instructions'] ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor),
              ),
            ),

            const SizedBox(height: 25),

            Row(
              children: [

                Expanded(
                  child: actionCard(
                    context,
                    Icons.alarm,
                    "Reminder",
                    const Color(0xffEAF1FF),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: actionCard(
                    context,
                    Icons.check_circle,
                    "Logged Today",
                    const Color(0xffE8F8EE),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  infoRow(
                    context,
                    Icons.person_outline,
                    "Prescribed By",
                    "Dr. test",
                  ),

                  const Divider(),

                  infoRow(
                    context,
                    Icons.calendar_today_outlined,
                    "Duration",
                    medication['duration'] ?? '',
                  ),

                  const Divider(),

                  infoRow(
                    context,
                    Icons.monitor_weight_outlined,
                    "Dosage",
                    medication['dosage'] ?? '',
                  ),

                  const Divider(),

                  infoRow(
                    context,
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
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientDoctorChatScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff1A2A4A) : const Color(0xffEEF4FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [

                    CircleAvatar(
                      radius: 24,
                      backgroundColor: isDark ? const Color(0xff121212) : Colors.white,
                      child: const Icon(
                        Icons.chat,
                        color: Color(0xff2F6FED),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Need help with this medication?",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "Message your doctor directly.",
                            style: TextStyle(color: subtextColor),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: textColor,
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
                  backgroundColor: const Color(0xff2F6FED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PatientDoctorChatScreen(),
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
                    fontWeight: FontWeight.bold,
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
    BuildContext context,
    IconData icon,
    String title,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    Color circleBg = color;
    if (isDark) {
      if (color == const Color(0xffEAF1FF)) {
        circleBg = const Color(0xff1A2A4A);
      } else if (color == const Color(0xffE8F8EE)) {
        circleBg = const Color(0xff1A3B2B);
      }
    }

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          CircleAvatar(
            radius: 24,
            backgroundColor: circleBg,
            child: Icon(
              icon,
              color: const Color(0xff2F6FED),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Row(
      children: [

        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xff121212) : const Color(0xffF4F6FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: subtextColor,
            ),
          ),
        ),

        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}