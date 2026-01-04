import 'package:flutter/material.dart';
import 'package:mensurationhealthapp/screens/home/home.dart';
import 'package:mensurationhealthapp/screens/home/learn.dart';
import 'package:mensurationhealthapp/screens/home/profile.dart';
import 'package:mensurationhealthapp/screens/home/user_notifications.dart';
import 'package:mensurationhealthapp/screens/home/admin/admin_dashboard.dart';
import 'package:mensurationhealthapp/screens/home/admin/admin_profile.dart';
import 'package:mensurationhealthapp/screens/home/admin/admin_send_notifications.dart';
import 'package:provider/provider.dart';
import 'package:mensurationhealthapp/providers/auth_provider.dart';
import 'package:mensurationhealthapp/screens/home/reports.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Widget> _getPages(bool isAdmin) {
    if (isAdmin) {
      return const [
        AdminDashboard(),
        AdminSendNotifications(),
        AdminProfile(),
      ];
    }
    return [
      HomePage(onProfileTabRequested: () => setState(() => _currentIndex = 4)),
      const LearnPage(),
      const NotificationPage(),
      const Reports(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isAdmin = authProvider.isAdmin;
    final List<Widget> pages = _getPages(isAdmin);

    // Guard clause for auth
    if (!authProvider.isAuth) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      // 1. Transparent status bar for a "Full Screen" feel
      extendBody: true, 
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      
      // 2. Conditional Bottom Bar with better styling
      bottomNavigationBar: isAdmin 
        ? _buildAdminNavBar(theme) // Admins deserve navigation too!
        : _buildUserNavBar(theme),
    );
  }

  Widget _buildUserNavBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            elevation: 0, // Handled by container shadow
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: theme.disabledColor,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.auto_stories_rounded), label: 'Learn'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications_none_rounded), label: 'Alerts'),
              BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Reports'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminNavBar(ThemeData theme) {
     return Container(
      margin: const EdgeInsets.all(16),
      height: 64,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _adminIconButton(0, Icons.dashboard_customize),
          _adminIconButton(1, Icons.campaign),
          _adminIconButton(2, Icons.admin_panel_settings),
        ],
      ),
    );
  }

  Widget _adminIconButton(int index, IconData icon) {
    final isSelected = _currentIndex == index;
    return IconButton(
      icon: Icon(icon, color: isSelected ? Colors.black : Colors.black45),
      onPressed: () => setState(() => _currentIndex = index),
    );
  }
}