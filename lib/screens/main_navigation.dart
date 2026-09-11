import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../utils/calculator_utils.dart';
import 'my_courses_screen.dart';
import 'calculate_cgpa_screen.dart';
import 'profile_screen.dart';
import 'home_screens.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const MyCoursesScreen(),
    const CalculateCgpaScreen(),
    const Center(child: Text('Semester Report (Coming Soon)')),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(_selectedIndex), 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF0F172A),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                child: Row(
                  children: [
                    Icon(Icons.school_rounded, color: Colors.blue.shade400, size: 32),
                    const SizedBox(width: 12),
                    const Text(
                      'CGPA Tracker',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                children: [
                  _buildDrawerItem(index: 0, icon: Icons.home_rounded, title: 'Home'),
                  _buildDrawerItem(index: 1, icon: Icons.library_books_rounded, title: 'My Courses'),
                  _buildDrawerItem(index: 2, icon: Icons.calculate_rounded, title: 'Calculate CGPA'),
                  _buildDrawerItem(index: 3, icon: Icons.assessment_rounded, title: 'Semester Report'),
                  _buildDrawerItem(index: 4, icon: Icons.more_horiz_rounded, title: 'More / Profile'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.workspace_premium_rounded, color: Colors.orange, size: 24),
                    ),
                    const SizedBox(height: 12),
                    const Text('Upgrade to Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    const Text('Get more features, remove ads and more!', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Go Premium', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }

  Widget _buildDrawerItem({required int index, required IconData icon, required String title}) {
    final isSelected = _selectedIndex == index;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade600 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.blueGrey.shade300, size: 24),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blueGrey.shade300,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        onTap: () => _onItemTapped(index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0: return 'Dashboard';
      case 1: return 'My Courses';
      case 2: return 'Calculate CGPA';
      case 3: return 'Semester Report';
      case 4: return 'Profile Settings';
      default: return '';
    }
  }
}