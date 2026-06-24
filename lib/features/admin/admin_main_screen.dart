import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_settings_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int currentIndex = 0;

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      AdminDashboardScreen(onNavigate: changeTab),
      const AdminUsersScreen(),
      const AdminReportsScreen(),
      const AdminSettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xff1E1E1E) : Colors.white,
        selectedItemColor: const Color(0xff2B82F6),
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[500] : Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: changeTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Users",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Reports",
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
