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
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.red.shade100,
                  child: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 28),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Delete Patient?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Are you sure you want to remove this patient from the referral system? This action cannot be undone and all associated records will be permanently deleted.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, height: 1.4),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xffF0F2F5),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black),
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
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(Icons.check,
                      color: Colors.green, size: 30),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Update Successful",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "The patient information has been successfully updated.",
                  textAlign: TextAlign.center,
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
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      appBar: AppBar(
        title: const Text("Edit Patient"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          sectionTitle("BASIC INFORMATION"),
          const SizedBox(height: 10),

          inputField("Full Name", controller: nameController),
          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(child: inputField("Age", controller: ageController)),
              const SizedBox(width: 10),
              Expanded(child: genderToggle()),
            ],
          ),

          const SizedBox(height: 15),
          dropdownField(),

          const SizedBox(height: 25),

          sectionTitle("PATIENT STATUS"),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xffEDEFF2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                statusBtn("ACTIVE"),
                statusBtn("REVIEW"),
                statusBtn("REJECTED"),
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
                    color: const Color(0xffF0F2F5),
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

  Widget sectionTitle(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
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

  Widget inputField(String hint,
      {required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xffF0F2F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget genderToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xffEDEFF2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          genderBtn("Male"),
          genderBtn("Female"),
        ],
      ),
    );
  }

  Widget genderBtn(String text) {
    bool selected = gender == text;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => gender = text),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: selected ? const Color(0xff2F6FED) : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget dropdownField() {
    return DropdownButtonFormField<String>(
      value: addiction,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xffF0F2F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      items: addictions
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => setState(() => addiction = v!),
    );
  }

  Widget statusBtn(String text) {
    bool selected = status == text;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => status = text),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: selected ? const Color(0xff2F6FED) : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}