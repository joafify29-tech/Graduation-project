import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportScreen extends StatefulWidget {
  final String title;
  const ContactSupportScreen({super.key, required this.title});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      String patientName = "Unknown Patient";

      if (uid != null) {
        final doc = await FirebaseFirestore.instance.collection('referrals').doc(uid).get();
        if (doc.exists) {
          patientName = doc.data()?['name'] ?? "Unknown Patient";
        }
      }

      // Format WhatsApp Message
      final message = "from AI recovery app - sender name $patientName - ${_msgCtrl.text}";
      
      // WhatsApp URL
      final Uri whatsappUri = Uri.parse("whatsapp://send?phone=+201500009775&text=\${Uri.encodeComponent(message)}");
      
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
        
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Message Sent!"),
              content: const Text("We got your message, we will get back to you shortly. Thank you!"),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close screen
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff2F6FED)),
                  child: const Text("OK", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Could not open WhatsApp. Please ensure it is installed."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: \$e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          widget.title,
          style: TextStyle(color: textColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "How can we help you?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Fill out the form below and we will contact you via WhatsApp or Email as soon as possible.",
                style: TextStyle(color: subtextColor, height: 1.5),
              ),
              const SizedBox(height: 30),

              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: "Your Email Address",
                  labelStyle: TextStyle(color: subtextColor),
                  prefixIcon: Icon(Icons.email_outlined, color: subtextColor),
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Email is required";
                  if (!val.contains('@')) return "Enter a valid email";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _msgCtrl,
                maxLines: 5,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  labelText: "Your Message",
                  labelStyle: TextStyle(color: subtextColor),
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Message cannot be empty";
                  return null;
                },
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2F6FED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Submit",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
