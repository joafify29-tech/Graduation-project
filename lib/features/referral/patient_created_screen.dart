import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PatientCreatedScreen extends StatelessWidget {
  final String email;
  final String password;

  const PatientCreatedScreen({
    super.key,
    required this.email,
    required this.password,
  });

  // 🔥 Dialog
  void showDeliveredDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: isDark ? const Color(0x1a34a853) : Colors.green.shade100,
                  child: const Icon(Icons.check,
                      color: Colors.green, size: 30),
                ),

                const SizedBox(height: 20),

                Text(
                  "Credentials Delivered",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "The access credentials have been successfully logged as delivered.\n\nThe patient can now log into the recovery application.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subtextColor),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2F6FED),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // close dialog
                      Navigator.pop(context); // close created screen
                      Navigator.pop(context); // back to dashboard
                    },
                    child: const Text("Back to Patient Profile"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF3F4F6);
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 30),

              CircleAvatar(
                radius: 35,
                backgroundColor: isDark ? const Color(0x1a34a853) : Colors.green.shade100,
                child: const Icon(Icons.check, color: Colors.green, size: 30),
              ),

              const SizedBox(height: 20),

              Text(
                "Patient Account Created",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),

              const SizedBox(height: 10),

              Text(
                "Please share these credentials with the patient.",
                textAlign: TextAlign.center,
                style: TextStyle(color: subtextColor),
              ),

              const SizedBox(height: 30),

              buildBox(context, "USERNAME", email),

              const SizedBox(height: 15),

              buildBox(context, "TEMPORARY PASSWORD", password),

              const SizedBox(height: 20),

              const Text(
                "⚠ Patient will be required to change this upon first login.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2F6FED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    showDeliveredDialog(context); // 🔥 هنا التعديل
                  },
                  child: const Text("Confirm Credentials Delivered"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBox(BuildContext context, String title, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boxBg = isDark ? const Color(0xff1E1E1E) : Colors.grey.shade200;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: subtextColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),

          IconButton(
            icon: Icon(Icons.copy, color: textColor),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
            },
          ),
        ],
      ),
    );
  }
}