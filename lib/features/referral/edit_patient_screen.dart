import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPatientScreen extends StatefulWidget {
  final dynamic data;
  final String docId;

  const EditPatientScreen({
    super.key,
    required this.data,
    required this.docId,
  });

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController notesController;

  String gender = "Male";
  String addiction = "Hashish";
  String status = "ACTIVE";

  final List<String> addictions = [
    "Hashish",
    "Alcohol",
    "Tramadol",
    "Ice",
    "Cocaine"
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.data['name']);
    ageController =
        TextEditingController(text: widget.data['age'].toString());
    notesController =
        TextEditingController(text: widget.data['notes'] ?? "");

    gender = widget.data['gender'] ?? "Male";

    String incomingAddiction =
        (widget.data['addiction'] ?? "").toString().trim();

    addiction = addictions.contains(incomingAddiction)
        ? incomingAddiction
        : "Hashish";

    status = widget.data['status'] ?? "ACTIVE";
  }

  Future<void> updatePatient() async {
    await FirebaseFirestore.instance
        .collection('referrals')
        .doc(widget.docId)
        .update({
      'name': nameController.text,
      'age': ageController.text,
      'gender': gender,
      'addiction': addiction,
      'notes': notesController.text,
      'status': status,
    });

    showSuccessDialog();
  }

  // 🔥 DELETE POPUP
  void deletePatient() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;
    final inputBg = isDark ? const Color(0xff2A2A2A) : const Color(0xffF0F2F5);

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isDark ? const Color(0xff450a0a) : Colors.red.shade100,
                  child: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 28),
                ),
                const SizedBox(height: 20),
                Text(
                  "Delete Patient?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Are you sure you want to remove this patient from the referral system? This action cannot be undone and all associated records will be permanently deleted.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subtextColor, height: 1.4),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xffEF4444),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('referrals')
                                .doc(widget.docId)
                                .delete();

                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Delete",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: isDark ? const Color(0xff062f17) : Colors.green.shade100,
                  child: const Icon(Icons.check,
                      color: Colors.green, size: 30),
                ),
                const SizedBox(height: 20),
                Text(
                  "Update Successful",
                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 10),
                Text(
                  "The patient information has been successfully updated.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subtextColor),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("Done"),
                )
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
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);
    final inputBg = isDark ? const Color(0xff2A2A2A) : const Color(0xffF0F2F5);
    final containerBg = isDark ? const Color(0xff222222) : const Color(0xffEDEFF2);

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        title: Text("Edit Patient", style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          sectionTitle(context, "BASIC INFORMATION"),
          const SizedBox(height: 10),

          inputField(context, "Full Name", controller: nameController),
          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(child: inputField(context, "Age", controller: ageController)),
              const SizedBox(width: 10),
              Expanded(child: genderToggle(context)),
            ],
          ),

          const SizedBox(height: 15),
          dropdownField(context),

          const SizedBox(height: 25),

          sectionTitle(context, "PATIENT STATUS"),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: containerBg,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                statusBtn(context, "ACTIVE"),
                statusBtn(context, "REVIEW"),
                statusBtn(context, "REJECTED"),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 🔥 BUTTONS
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: deletePatient,
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                        color: Color(0xffEF4444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xff2F6FED),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: updatePatient,
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget sectionTitle(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secBg = isDark ? const Color(0xff1E3A8A).withValues(alpha: 0.3) : Colors.blue.shade50;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: secBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xff2F6FED),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget inputField(BuildContext context, String hint,
      {required TextEditingController controller}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputBg = isDark ? const Color(0xff2A2A2A) : const Color(0xffF0F2F5);
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);

    return TextField(
      controller: controller,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: subtextColor),
        filled: true,
        fillColor: inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget genderToggle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? const Color(0xff222222) : const Color(0xffEDEFF2);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          genderBtn(context, "Male"),
          genderBtn(context, "Female"),
        ],
      ),
    );
  }

  Widget genderBtn(BuildContext context, String text) {
    bool selected = gender == text;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btnBg = selected 
        ? (isDark ? const Color(0xff1E1E1E) : Colors.white) 
        : Colors.transparent;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => gender = text),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: btnBg,
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: selected ? const Color(0xff2F6FED) : (isDark ? Colors.grey[400]! : Colors.grey),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget dropdownField(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final inputBg = isDark ? const Color(0xff2A2A2A) : const Color(0xffF0F2F5);
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);

    return DropdownButtonFormField<String>(
      value: addiction,
      dropdownColor: cardBg,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        filled: true,
        fillColor: inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      items: addictions
          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: textColor))))
          .toList(),
      onChanged: (v) => setState(() => addiction = v!),
    );
  }

  Widget statusBtn(BuildContext context, String text) {
    bool selected = status == text;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btnBg = selected 
        ? (isDark ? const Color(0xff1E1E1E) : Colors.white) 
        : Colors.transparent;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => status = text),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: btnBg,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: selected ? const Color(0xff2F6FED) : (isDark ? Colors.grey[400]! : Colors.grey),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}