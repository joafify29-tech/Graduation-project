import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/login_screen.dart';
import 'change_password_screen.dart';
import 'help_center_screen.dart';
import 'contact_support_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';
import 'security_settings_screen.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;
    final cancelBtnBg = isDark ? const Color(0xff2A2A2A) : const Color(0xffF0F2F5);
    final cancelBtnText = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (dialogContext) {
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
                  backgroundColor: isDark ? const Color(0x1aff4444) : Colors.red.shade100,
                  child: const Icon(Icons.logout,
                      color: Colors.red, size: 28),
                ),
                const SizedBox(height: 20),
                Text(
                  "Log Out?",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
                ),
                const SizedBox(height: 10),
                Text(
                  "Are you sure you want to log out of your account? You will need to enter your credentials to access the system again.",
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
                          color: cancelBtnBg,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: cancelBtnText),
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
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            logout(context);
                          },
                          child: const Text(
                            "Yes, Log Out",
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
              snapshot.data!.data() as Map<String, dynamic>? ?? {};

          final name = data['name'] ?? "Patient";
          final email = data['email'] ?? "";
          final addiction = data['addiction'] ?? "";
          final doctorName = data['doctorName'] ?? "Not Assigned";

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Account Settings",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.notifications_none,
                          color: isDark ? Colors.white70 : const Color(0xff2F6FED),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// PROFILE CARD
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundColor: const Color(0xffD8C2AD),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : "P",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    email,
                                    style: TextStyle(
                                      color: subtextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xff1A3B2B) : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "ACTIVE",
                                style: TextStyle(
                                  color: Color(0xff34C759),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Recovery Focus",
                              style: TextStyle(
                                color: subtextColor,
                              ),
                            ),
                            Text(
                              addiction,
                              style: TextStyle(
                                color: isDark ? Colors.blue.shade300 : const Color(0xff2F6FED),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Primary Doctor",
                              style: TextStyle(
                                color: subtextColor,
                              ),
                            ),
                            Text(
                              doctorName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    "GENERAL SETTINGS",
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1,
                      color: subtextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        settingsTile(
                          context,
                          Icons.edit_outlined,
                          "Edit Profile",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                        settingsTile(
                          context,
                          Icons.lock_outline,
                          "Change Password",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChangePasswordScreen(),
                              ),
                            );
                          },
                        ),
                        settingsTile(
                          context,
                          Icons.notifications_none,
                          "Notification Preferences",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationSettingsScreen(),
                              ),
                            );
                          },
                        ),
                        settingsTile(
                          context,
                          Icons.shield_outlined,
                          "Privacy Settings",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrivacyScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "SUPPORT",
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1,
                      color: subtextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        settingsTile(
                          context,
                          Icons.help_outline,
                          "Help Center",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SupportScreen(),
                              ),
                            );
                          },
                        ),
                        settingsTile(
                          context,
                          Icons.description,
                          "Terms of Service",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TermsConditionsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xff3A1A1A) : const Color(0xffFFE5E5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        showLogoutDialog(context);
                      },
                      child: const Text(
                        "Log Out",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      "AI Recovery v2.4.0",
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 12,
                      ),
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

  Widget settingsTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff1A2A4A) : const Color(0xffEEF4FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.blue.shade300 : const Color(0xff2F6FED),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: subtextColor,
      ),
      onTap: onTap,
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  String gender = "Male";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection("referrals")
        .doc(uid)
        .get();

    final data = doc.data() ?? {};

    nameController.text = data['name'] ?? "";
    emailController.text = data['email'] ?? "";
    ageController.text = data['age']?.toString() ?? "";
    gender = data['gender'] ?? "Male";

    setState(() {
      loading = false;
    });
  }

  Future<void> saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("referrals")
        .doc(uid)
        .update({
      "name": nameController.text,
      "email": emailController.text,
      "age": int.tryParse(ageController.text) ?? 0,
      "gender": gender,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile Updated"),
      ),
    );

    Navigator.pop(context);
  }

  Widget modernField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final textColor = isDark ? Colors.white : Colors.black;

    if (loading) {
      return Scaffold(
        backgroundColor: bg,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "Edit Profile",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            modernField(
              context: context,
              label: "Full Name",
              controller: nameController,
            ),
            const SizedBox(height: 15),
            modernField(
              context: context,
              label: "Email",
              controller: emailController,
            ),
            const SizedBox(height: 15),
            modernField(
              context: context,
              label: "Age",
              controller: ageController,
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Gender",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: gender,
              dropdownColor: isDark ? const Color(0xff1E1E1E) : Colors.white,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xff1E1E1E) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Male",
                  child: Text("Male"),
                ),
                DropdownMenuItem(
                  value: "Female",
                  child: Text("Female"),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  gender = v!;
                });
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2F6FED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: saveProfile,
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool medicationAlerts = true;
  bool moodCheckIn = true;
  bool journalingReminder = true;
  bool groupMessages = true;
  bool milestones = true;
  bool supportRequests = true;
  bool appUpdates = true;

  Widget switchTile(
    BuildContext context,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xff2F6FED),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "Notifications",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          switchTile(
            context,
            "Medication Alerts",
            medicationAlerts,
            (v) {
              setState(() {
                medicationAlerts = v;
              });
            },
          ),
          switchTile(
            context,
            "Mood Check-ins",
            moodCheckIn,
            (v) {
              setState(() {
                moodCheckIn = v;
              });
            },
          ),
          switchTile(
            context,
            "Journaling Reminders",
            journalingReminder,
            (v) {
              setState(() {
                journalingReminder = v;
              });
            },
          ),
          switchTile(
            context,
            "Group Messages",
            groupMessages,
            (v) {
              setState(() {
                groupMessages = v;
              });
            },
          ),
          switchTile(
            context,
            "Recovery Milestones",
            milestones,
            (v) {
              setState(() {
                milestones = v;
              });
            },
          ),
          switchTile(
            context,
            "Support Requests",
            supportRequests,
            (v) {
              setState(() {
                supportRequests = v;
              });
            },
          ),
          switchTile(
            context,
            "App Updates",
            appUpdates,
            (v) {
              setState(() {
                appUpdates = v;
              });
            },
          ),
        ],
      ),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  Widget tile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback? onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isDark ? Colors.blue.shade300 : const Color(0xff2F6FED),
          ),
          title: Text(
            title,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: subtextColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "Privacy & Security",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            tile(
              context,
              Icons.lock_outline,
              "Change Password",
              () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
              },
            ),
            tile(
              context,
              Icons.privacy_tip_outlined,
              "Privacy Policy",
              () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
              },
            ),
            tile(
              context,
              Icons.description_outlined,
              "Terms & Conditions",
              () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsConditionsScreen()));
              },
            ),
            tile(
              context,
              Icons.security,
              "Security Settings",
              () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Widget supportCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isDark ? const Color(0xff1A2A4A) : const Color(0xffEEF4FF),
              child: Icon(
                icon,
                color: isDark ? Colors.blue.shade300 : const Color(0xff2F6FED),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
          "Support",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            supportCard(
              context,
              Icons.help_outline,
              "Help Center",
              "Find answers to common questions",
              () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterScreen()));
              },
            ),
            supportCard(
              context,
              Icons.support_agent,
              "Contact Support",
              "Get help from our team",
              () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactSupportScreen(title: "Contact Support")));
              },
            ),
            supportCard(
              context,
              Icons.local_hospital,
              "Contact Doctor",
              "Reach your assigned doctor",
              () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactSupportScreen(title: "Contact Doctor")));
              },
            ),
            supportCard(
              context,
              Icons.bug_report_outlined,
              "Report a Problem",
              "Send feedback or report bugs",
              () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactSupportScreen(title: "Report a Problem")));
              },
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 35,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "AI Recovery",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Version 2.4.0",
                    style: TextStyle(
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}