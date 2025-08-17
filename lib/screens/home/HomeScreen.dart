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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAdmin) {
      // Admin-specific pages
      _pages = [
        const AdminDashboard(),
        const AdminSendNotifications(),
        const AdminProfile(),
      ];
    } else {
      // Regular user pages
      _pages = [
        HomePage(onProfileTabRequested: () => setCurrentIndex(3)),
        const LearnPage(),
        const NotificationPage(),
        const ProfilePage(),
      ];
    }
  }

  void setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuth) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: authProvider.isAdmin 
          ? null 
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setCurrentIndex(index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: theme.cardColor,
              selectedItemColor: theme.colorScheme.primary,
              unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
              selectedLabelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book_sharp),
                  label: 'Learn',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications),
                  label: 'Notification',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
    );
  }
}