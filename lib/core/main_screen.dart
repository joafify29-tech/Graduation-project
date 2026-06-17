import 'package:flutter/material.dart';
import '../features/referral/referral_home_screen.dart';
import '../features/referral/referral_history_screen.dart';
import '../features/referral/add_patient_screen.dart';
import '../features/referral/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  final List<Widget> screens = [
    const ReferralHomeScreen(),
    const AddPatientScreen(),
    const ReferralHistoryScreen(),
    const SettingsScreen(), // 🔥 بدل الـ Scaffold الوهمي
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xff2F6FED),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // 🔥 عشان الشكل يظبط

        onTap: changeTab,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: "Add Patient",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Referrals",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}