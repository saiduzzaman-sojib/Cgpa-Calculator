import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screens.dart';
import 'calculate_cgpa_screen.dart';
import 'semester_report_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  String _drawerUserName = 'Md Saiduzzaman';
  String? _drawerImagePath;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const CalculateCgpaScreen(),
    const SemesterReportScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadDrawerUserData();
  }

  Future<void> _loadDrawerUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _drawerUserName = prefs.getString('user_name') ?? 'Md Saiduzzaman';
      _drawerImagePath = prefs.getString('profile_image_path');
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _loadDrawerUserData();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _getAppBarTitle(_selectedIndex), 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
          iconTheme: IconThemeData(color: theme.colorScheme.primary),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () {
                _loadDrawerUserData();
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ),
        drawer: Drawer(
          backgroundColor: const Color(0xFF0F172A),
          child: Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.school_rounded, color: Colors.blue.shade400, size: 28),
                          const SizedBox(width: 10),
                          const Text(
                            'CGPA Tracker',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => _onItemTapped(3),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.blue.shade600,
                                backgroundImage: _drawerImagePath != null ? FileImage(File(_drawerImagePath!)) : null,
                                child: _drawerImagePath == null
                                    ? const Icon(Icons.person_rounded, size: 30, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _drawerUserName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      'View Profile',
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  children: [
                    _buildDrawerItem(index: 0, icon: Icons.home_rounded, title: 'Home'),
                    _buildDrawerItem(index: 1, icon: Icons.calculate_rounded, title: 'Calculate CGPA'),
                    _buildDrawerItem(index: 2, icon: Icons.assessment_rounded, title: 'Semester Report'),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'DEVELOPED BY',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: Colors.white38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Md Saiduzzaman Sojib',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 100, 212, 246),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: _screens[_selectedIndex],
      ),
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
      case 1: return 'Calculate CGPA';
      case 2: return 'Semester Report';
      case 3: return 'Profile Settings';
      default: return '';
    }
  }
}