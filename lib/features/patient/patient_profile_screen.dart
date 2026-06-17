import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/login_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

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
                      as Map<String, dynamic>? ??
                  {};

          final name =
              data['name'] ?? "Patient";

          final email =
              data['email'] ?? "";

          final addiction =
              data['addiction'] ?? "";

          final doctorName =
              data['doctorName'] ??
                  "Not Assigned";

          return SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  /// HEADER

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [

                      const Text(
                        "Account Settings",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons
                              .notifications_none,
                          color: Color(
                              0xff2F6FED),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 20),

                  /// PROFILE CARD

                  Container(
                    padding:
                        const EdgeInsets.all(
                            18),
                    decoration: BoxDecoration(
  color: Colors.white,
  borderRadius:
      BorderRadius.circular(24),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 15,
      offset: Offset(0, 5),
    ),
  ],
),
                    child: Column(
                      children: [

                        Row(
                          children: [

                            CircleAvatar(
  radius: 42,
                              backgroundColor:
                                  const Color(
                                      0xffD8C2AD),
                              child: Text(
                                name
                                        .isNotEmpty
                                    ? name[0]
                                        .toUpperCase()
                                    : "P",
                                style:
                                    const TextStyle(
                                  color: Colors
                                      .white,
                                  fontSize:
                                      28,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),

                            const SizedBox(
                                width: 15),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [

                                  Text(
                                    name,
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          20,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          4),

                                  Text(
                                    email,
                                    style:
                                        const TextStyle(
                                      color: Colors
                                          .grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    12,
                                vertical: 5,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: Colors
                                    .green
                                    .shade100,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            20),
                              ),
                              child:
                                  const Text(
                                "ACTIVE",
                                style:
                                    TextStyle(
                                  color: Colors
                                      .green,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                            height: 20),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [

                            const Text(
                              "Recovery Focus",
                              style:
                                  TextStyle(
                                color: Colors
                                    .grey,
                              ),
                            ),

                            Text(
                              addiction,
                              style:
                                  const TextStyle(
                                color: Color(
                                    0xff2F6FED),
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                            height: 15),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [

                            const Text(
                              "Primary Doctor",
                              style:
                                  TextStyle(
                                color: Colors
                                    .grey,
                              ),
                            ),

                            Text(
                              doctorName,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 30),

                  const Text(
                    "GENERAL SETTINGS",
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1,
                      color: Colors.grey,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  Container(
                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius
                              .circular(
                                  22),
                    ),
                    child: Column(
                      children: [

                        settingsTile(
                          Icons.edit_outlined,
                          "Edit Profile",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const EditProfileScreen(),
                              ),
                            );
                          },
                        ),

                        settingsTile(
                          Icons.lock_outline,
                          "Change Password",
                          () {},
                        ),

                        settingsTile(
                          Icons
                              .notifications_none,
                          "Notification Preferences",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const NotificationSettingsScreen(),
                              ),
                            );
                          },
                        ),

                        settingsTile(
                          Icons
                              .shield_outlined,
                          "Privacy Settings",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PrivacyScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 25),

                  const Text(
                    "SUPPORT",
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1,
                      color: Colors.grey,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  Container(
                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius
                              .circular(
                                  22),
                    ),
                    child: Column(
                      children: [

                        settingsTile(
                          Icons.help_outline,
                          "Help Center",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const SupportScreen(),
                              ),
                            );
                          },
                        ),

                        settingsTile(
                          Icons.description,
                          "Terms of Service",
                          () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 30),

                 SizedBox(
  width: double.infinity,
  height: 55,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xffFFE5E5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
    onPressed: () {

      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(25),
            ),
            title: const Text(
              "Log Out?",
            ),
            content: const Text(
              "Are you sure you want to log out?",
            ),
            actions: [

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Keep Me Logged In",
                ),
              ),

              TextButton(
                onPressed: () {
                  logout(context);
                },
                child: const Text(
                  "Yes, Log Out",
                ),
              ),
            ],
          );
        },
      );
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

                  const SizedBox(
                      height: 20),

                  const Center(
                    child: Text(
                      "AI Recovery v2.4.0",
                      style:
                          TextStyle(
                        color:
                            Colors.grey,
                        fontSize:
                            12,
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
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding:
            const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              const Color(0xffEEF4FF),
          borderRadius:
              BorderRadius.circular(
                  12),
        ),
        child: Icon(
          icon,
          color:
              const Color(0xff2F6FED),
        ),
      ),
      title: Text(title),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

  final nameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final ageController =
      TextEditingController();

  String gender = "Male";

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {

    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    final doc =
        await FirebaseFirestore.instance
            .collection("referrals")
            .doc(uid)
            .get();

    final data = doc.data() ?? {};

    nameController.text =
        data['name'] ?? "";

    emailController.text =
        data['email'] ?? "";

    ageController.text =
        data['age']?.toString() ?? "";

    gender =
        data['gender'] ?? "Male";

    setState(() {
      loading = false;
    });
  }

  Future<void> saveProfile() async {

    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("referrals")
        .doc(uid)
        .update({
      "name": nameController.text,
      "email": emailController.text,
      "age":
          int.tryParse(ageController.text) ?? 0,
      "gender": gender,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content:
            Text("Profile Updated"),
      ),
    );

    Navigator.pop(context);
  }
Widget modernField({
  required String label,
  required TextEditingController controller,
}) {
  return Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [

      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),

      const SizedBox(height: 8),

      TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  );
}
  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xffF7F8FA),

      appBar: AppBar(
        backgroundColor:
            const Color(0xffF7F8FA),
        elevation: 0,
        title:
            const Text("Edit Profile"),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller:
                  nameController,
              decoration:
                  const InputDecoration(
                labelText: "Name",
              ),
            ),

            const SizedBox(height: 15),

            modernField(
  label: "Full Name",
  controller: nameController,
),

const SizedBox(height: 15),

modernField(
  label: "Email",
  controller: emailController,
),

const SizedBox(height: 15),

modernField(
  label: "Age",
  controller: ageController,
),

const SizedBox(height: 15),

            DropdownButtonFormField(
              value: gender,
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

            const Spacer(),

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
                child:
                    const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationSettingsScreen
    extends StatefulWidget {

  const NotificationSettingsScreen({
    super.key,
  });

  @override
  State<NotificationSettingsScreen>
      createState() =>
          _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<
        NotificationSettingsScreen> {

  bool medicationAlerts = true;

  bool moodCheckIn = true;

  bool journalingReminder = true;

  bool groupMessages = true;

  bool milestones = true;

  bool supportRequests = true;

  bool appUpdates = true;

  Widget switchTile(
  String title,
  bool value,
  Function(bool) onChanged,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [

        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xffF7F8FA),

      appBar: AppBar(
        backgroundColor:
            const Color(0xffF7F8FA),
        elevation: 0,
        title: const Text(
          "Notifications",
        ),
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [

          switchTile(
            "Medication Alerts",
            medicationAlerts,
            (v) {
              setState(() {
                medicationAlerts = v;
              });
            },
          ),

          switchTile(
            "Mood Check-ins",
            moodCheckIn,
            (v) {
              setState(() {
                moodCheckIn = v;
              });
            },
          ),

          switchTile(
            "Journaling Reminders",
            journalingReminder,
            (v) {
              setState(() {
                journalingReminder = v;
              });
            },
          ),

          switchTile(
            "Group Messages",
            groupMessages,
            (v) {
              setState(() {
                groupMessages = v;
              });
            },
          ),

          switchTile(
            "Recovery Milestones",
            milestones,
            (v) {
              setState(() {
                milestones = v;
              });
            },
          ),

          switchTile(
            "Support Requests",
            supportRequests,
            (v) {
              setState(() {
                supportRequests = v;
              });
            },
          ),

          switchTile(
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
    IconData icon,
    String title,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xff2F6FED),
        ),
        title: Text(title),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
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
        title: const Text(
          "Privacy & Security",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            tile(
              Icons.lock_outline,
              "Change Password",
            ),

            tile(
              Icons.privacy_tip_outlined,
              "Privacy Policy",
            ),

            tile(
              Icons.description_outlined,
              "Terms & Conditions",
            ),

            tile(
              Icons.security,
              "Security Settings",
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
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [

          CircleAvatar(
            backgroundColor:
                const Color(0xffEEF4FF),
            child: Icon(
              icon,
              color:
                  const Color(0xff2F6FED),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xffF7F8FA),

      appBar: AppBar(
        backgroundColor:
            const Color(0xffF7F8FA),
        elevation: 0,
        title:
            const Text("Support"),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [

            supportCard(
              Icons.help_outline,
              "Help Center",
              "Find answers to common questions",
            ),

            supportCard(
              Icons.support_agent,
              "Contact Support",
              "Get help from our team",
            ),

            supportCard(
              Icons.local_hospital,
              "Contact Doctor",
              "Reach your assigned doctor",
            ),

            supportCard(
              Icons.bug_report_outlined,
              "Report a Problem",
              "Send feedback or report bugs",
            ),

            const SizedBox(height: 30),

            Container(
              padding:
                  const EdgeInsets.all(20),
              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                        25),
              ),
              child: const Column(
                children: [

                  Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 35,
                  ),

                  SizedBox(height: 12),

                  Text(
                    "AI Recovery",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Version 2.4.0",
                    style: TextStyle(
                      color: Colors.grey,
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