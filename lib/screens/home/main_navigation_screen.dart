import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mensurationhealthapp/providers/auth_provider.dart';
import 'package:mensurationhealthapp/screens/home/home.dart';
import 'package:mensurationhealthapp/screens/home/learn.dart';
import 'package:mensurationhealthapp/screens/home/profile.dart';
import 'package:mensurationhealthapp/screens/home/reports.dart';
import 'package:mensurationhealthapp/screens/home/user_notifications.dart';

class MainNavigationScreen
    extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
  });

  @override
  State<MainNavigationScreen>
      createState() =>
          _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<
        MainNavigationScreen> {
  int _currentIndex = 0;

  // ==========================================
  // PAGES
  // ==========================================

  final List<Widget> _pages =
      const [
    HomeScreen(),


    LearnPage(),

    NotificationPage(),

    Reports(),

    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final authProvider =
        Provider.of<AuthProvider>(
      context,
    );

    // ==========================================
    // AUTH GUARD
    // ==========================================

    if (!authProvider.isAuth) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(
          context,
          '/login',
        );
      });

      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      extendBody: true,

      backgroundColor:
          const Color(0xFFF6F7FB),

      body: AnimatedSwitcher(
        duration:
            const Duration(
          milliseconds: 250,
        ),

        child: IndexedStack(
          key: ValueKey(
            _currentIndex,
          ),

          index: _currentIndex,

          children: _pages,
        ),
      ),

      // ======================================
      // NAVIGATION BAR
      // ======================================

      bottomNavigationBar:
          _buildBottomNavBar(theme),
    );
  }

  // ==========================================
  // BOTTOM NAVBAR
  // ==========================================

  Widget _buildBottomNavBar(
    ThemeData theme,
  ) {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        18,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.06),

            blurRadius: 20,

            offset:
                const Offset(0, 10),
          ),
        ],
      ),

      child: SafeArea(
        top: false,

        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 8,
          ),

          child: BottomNavigationBar(
            currentIndex:
                _currentIndex,

            onTap: (index) {
              setState(() {
                _currentIndex =
                    index;
              });
            },

            type:
                BottomNavigationBarType
                    .fixed,

            backgroundColor:
                Colors.transparent,

            elevation: 0,

            selectedItemColor:
                theme
                    .colorScheme
                    .primary,

            unselectedItemColor:
                Colors.grey.shade500,

            selectedLabelStyle:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 12,
            ),

            unselectedLabelStyle:
                const TextStyle(
              fontSize: 11,
            ),

            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(
                  Icons.home_rounded,
                  0,
                ),

                label: 'Home',
              ),

              BottomNavigationBarItem(
                icon: _buildNavIcon(
                  Icons.menu_book_rounded,
                  1,
                ),

                label: 'Learn',
              ),

              BottomNavigationBarItem(
                icon: _buildNavIcon(
                  Icons.notifications_rounded,
                  2,
                ),

                label: 'Alerts',
              ),

              BottomNavigationBarItem(
                icon: _buildNavIcon(
                  Icons.analytics_rounded,
                  3,
                ),

                label: 'Reports',
              ),

              BottomNavigationBarItem(
                icon: _buildNavIcon(
                  Icons.person_rounded,
                  4,
                ),

                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // NAV ICON
  // ==========================================

  Widget _buildNavIcon(
    IconData icon,
    int index,
  ) {
    final bool isSelected =
        _currentIndex == index;

    return AnimatedContainer(
      duration:
          const Duration(
        milliseconds: 250,
      ),

      padding:
          const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.12)
            : Colors.transparent,

        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Icon(
        icon,
        size: 24,
      ),
    );
  }
}