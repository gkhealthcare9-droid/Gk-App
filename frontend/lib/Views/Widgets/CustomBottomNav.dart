import 'package:flutter/material.dart';
import 'package:sales_grow/Views/Tasks/MyTaskScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/Colors.dart';
import '../AuthScreens/profile_Screen.dart';
import '../HomeScreen/HomeScreen.dart';
import '../Tasks/Create _Task_Screen.dart';
import '../Tasks/Task_Screen.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int _selectedIndex = 0;
  String? _userType;

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userType = prefs.getString('userType');
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildIcon(IconData icon, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryBlue.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        // REMOVED ALL BORDERS AND OUTLINES
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.accentBlue : AppColors.grey.withOpacity(0.4),
            size: 26,
          ),
          if (isActive) ...[
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.accentBlue,
                shape: BoxShape.circle,
              ),
            ),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userType == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      );
    }

    final isAdmin = _userType == 'admin';
    final pages = <Widget>[
      const HomeScreen(),
      if (isAdmin) const CreateTaskScreen(),
      (isAdmin ? const TaskListScreen() : const MyTaskListScreen()),
      const ProfileScreen(),
    ];
    final icons = <IconData>[
      Icons.dashboard_rounded,
      if (isAdmin) Icons.add_rounded,
      Icons.assignment_rounded,
      Icons.person_rounded,
    ];

    if (_selectedIndex >= pages.length) _selectedIndex = 0;

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: const EdgeInsets.only(bottom: 25, left: 30, right: 30),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          // REMOVED OUTLINES: Soft light-blue matching shadow
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(icons.length, (i) {
            return GestureDetector(
              onTap: () => _onItemTapped(i),
              child: _buildIcon(icons[i], _selectedIndex == i),
            );
          }),
        ),
      ),
    );
  }
}
