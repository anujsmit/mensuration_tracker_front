import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ======================================================
// PROVIDERS
// ======================================================

import '../../features/auth/providers/auth_provider.dart';
import '../../features/profile/providers/profile_provider.dart';

// ======================================================
// SCREENS
// ======================================================

import '../../features/auth/screens/login_screen.dart';

import '../../features/profile/screens/profile_screen.dart';

import '../../features/cycles/screens/add_cycle_screen.dart';

import '../../features/cycles/screens/cycle_history_screen.dart';

import '../../features/notes/screens/add_note_screen.dart';

import '../../features/symptoms/screens/symptom_screen.dart';

import '../../features/notifications/screens/notification_screen.dart';

import '../../features/reports/screens/report_screen.dart';

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
    extends State<MainNavigationScreen> {

  // ======================================================
  // INDEX
  // ======================================================

  int _currentIndex = 0;

  // ======================================================
  // SCREENS
  // ======================================================

  final List<Widget> _screens = [

    const HomeDashboard(),

    const CycleHistoryScreen(),

    const NotificationScreen(),

    const ProfileScreen(),

  ];

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      body: IndexedStack(

        index: _currentIndex,

        children: _screens,

      ),

      // ==================================================
      // FAB
      // ==================================================

      floatingActionButton:
          FloatingActionButton(

        backgroundColor:
            Colors.pink,

        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),

        onPressed: () {

          _showBottomSheet();

        },

      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation
              .centerDocked,

      // ==================================================
      // BOTTOM NAVIGATION
      // ==================================================

      bottomNavigationBar:
          BottomNavigationBar(

        currentIndex:
            _currentIndex,

        selectedItemColor:
            Colors.pink,

        unselectedItemColor:
            Colors.grey,

        type:
            BottomNavigationBarType.fixed,

        elevation: 10,

        onTap: (index) {

          setState(() {

            _currentIndex = index;

          });

        },

        items: const [

          BottomNavigationBarItem(

            icon:
                Icon(Icons.home),

            label: 'Home',

          ),

          BottomNavigationBarItem(

            icon:
                Icon(Icons.calendar_month),

            label: 'Cycles',

          ),

          BottomNavigationBarItem(

            icon:
                Icon(Icons.notifications),

            label:
                'Notifications',

          ),

          BottomNavigationBarItem(

            icon:
                Icon(Icons.person),

            label:
                'Profile',

          ),

        ],

      ),

    );

  }

  // ======================================================
  // BOTTOM SHEET
  // ======================================================

  void _showBottomSheet() {

    showModalBottomSheet(

      context: context,

      backgroundColor:
          Colors.white,

      shape:
          const RoundedRectangleBorder(

        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(30),
        ),

      ),

      builder: (_) {

        return SafeArea(

          child: Padding(

            padding:
                const EdgeInsets.all(20),

            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                _bottomTile(

                  icon:
                      Icons.water_drop,

                  title:
                      'Add Cycle',

                  onTap: () {

                    Navigator.pop(
                      context,
                    );

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) {

                          return const AddCycleScreen();

                        },

                      ),

                    );

                  },

                ),

                _bottomTile(

                  icon:
                      Icons.edit_note,

                  title:
                      'Daily Note',

                  onTap: () {

                    Navigator.pop(
                      context,
                    );

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) {

                          return const AddNoteScreen();

                        },

                      ),

                    );

                  },

                ),

                _bottomTile(

                  icon:
                      Icons.favorite,

                  title:
                      'Track Symptoms',

                  onTap: () {

                    Navigator.pop(
                      context,
                    );

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) {

                          return const SymptomScreen();

                        },

                      ),

                    );

                  },

                ),

              ],

            ),

          ),

        );

      },

    );

  }

  // ======================================================
  // TILE
  // ======================================================

  Widget _bottomTile({

    required IconData icon,

    required String title,

    required VoidCallback onTap,

  }) {

    return ListTile(

      leading: CircleAvatar(

        backgroundColor:
            Colors.pink.shade50,

        child: Icon(
          icon,
          color: Colors.pink,
        ),

      ),

      title: Text(title),

      trailing: const Icon(
        Icons.arrow_forward_ios,
      ),

      onTap: onTap,

    );

  }

}

// ======================================================
// HOME DASHBOARD
// ======================================================

class HomeDashboard
    extends StatefulWidget {

  const HomeDashboard({
    super.key,
  });

  @override
  State<HomeDashboard>
      createState() =>
          _HomeDashboardState();

}

class _HomeDashboardState
    extends State<HomeDashboard> {

  final supabase =
      Supabase.instance.client;

  Map<String, dynamic>? profile;

  bool isLoading = true;

  @override
  void initState() {

    super.initState();

    _loadData();

  }

  // ======================================================
  // LOAD DATA
  // ======================================================

  Future<void> _loadData()
      async {

    try {

      final profileProvider =
          Provider.of<ProfileProvider>(
        context,
        listen: false,
      );

      await profileProvider
          .fetchProfile();

      if (!mounted) return;

      setState(() {

        profile =
            profileProvider
                .profile
                ?.toJson();

        isLoading = false;

      });

    } catch (e) {

      setState(() {

        isLoading = false;

      });

    }

  }

  // ======================================================
  // LOGOUT
  // ======================================================

  Future<void> _logout()
      async {

    final authProvider =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    await authProvider.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(

      context,

      MaterialPageRoute(

        builder: (_) {

          return const LoginScreen();

        },

      ),

      (route) => false,

    );

  }

  @override
  Widget build(
    BuildContext context,
  ) {

    final theme =
        Theme.of(context);

    final primaryColor =
        theme.colorScheme.primary;

    final user =
        supabase.auth.currentUser;

    return Scaffold(

      backgroundColor:
          const Color(0xFFF6F7FB),

      appBar: AppBar(

        backgroundColor:
            Colors.transparent,

        elevation: 0,

        title: const Text(
          'Menstrual Health',
        ),

        actions: [

          IconButton(

            onPressed: () {

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) {

                    return const ProfileScreen();

                  },

                ),

              );

            },

            icon: const Icon(
              Icons.person_outline,
            ),

          ),

          IconButton(

            onPressed: _logout,

            icon: const Icon(
              Icons.logout,
            ),

          ),

        ],

      ),

      body:
          isLoading

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )

              : RefreshIndicator(

                  onRefresh:
                      _loadData,

                  child:
                      SingleChildScrollView(

                    physics:
                        const AlwaysScrollableScrollPhysics(),

                    padding:
                        const EdgeInsets.all(20),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        // ======================
                        // HEADER
                        // ======================

                        Container(

                          width:
                              double.infinity,

                          padding:
                              const EdgeInsets.all(24),

                          decoration:
                              BoxDecoration(

                            gradient:
                                LinearGradient(

                              colors: [

                                primaryColor,

                                primaryColor.withOpacity(0.7),

                              ],

                            ),

                            borderRadius:
                                BorderRadius.circular(28),

                          ),

                          child: Column(

                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              Text(

                                'Hello 👋',

                                style:
                                    TextStyle(

                                  color:
                                      Colors.white.withOpacity(0.9),

                                  fontSize: 18,

                                ),

                              ),

                              const SizedBox(height: 8),

                              Text(

                                profile?['full_name'] ??
                                    user?.email ??
                                    'User',

                                style:
                                    const TextStyle(

                                  color:
                                      Colors.white,

                                  fontSize: 28,

                                  fontWeight:
                                      FontWeight.bold,

                                ),

                              ),

                              const SizedBox(height: 14),

                              const Text(

                                'Track your cycle, moods, symptoms and health reports easily.',

                                style:
                                    TextStyle(

                                  color:
                                      Colors.white,

                                  height: 1.5,

                                ),

                              ),

                            ],

                          ),

                        ),

                        const SizedBox(height: 30),

                        // ======================
                        // QUICK ACTIONS
                        // ======================

                        Text(

                          'Quick Actions',

                          style:
                              theme.textTheme.titleLarge?.copyWith(

                            fontWeight:
                                FontWeight.bold,

                          ),

                        ),

                        const SizedBox(height: 18),

                        GridView.count(

                          crossAxisCount: 2,

                          shrinkWrap: true,

                          physics:
                              const NeverScrollableScrollPhysics(),

                          crossAxisSpacing: 16,

                          mainAxisSpacing: 16,

                          childAspectRatio: 1.1,

                          children: [

                            _actionCard(

                              title:
                                  'Track Cycle',

                              icon:
                                  Icons.water_drop,

                              color:
                                  Colors.pink,

                              onTap: () {

                                Navigator.push(

                                  context,

                                  MaterialPageRoute(

                                    builder: (_) {

                                      return const AddCycleScreen();

                                    },

                                  ),

                                );

                              },

                            ),

                            _actionCard(

                              title:
                                  'Symptoms',

                              icon:
                                  Icons.favorite,

                              color:
                                  Colors.red,

                              onTap: () {

                                Navigator.push(

                                  context,

                                  MaterialPageRoute(

                                    builder: (_) {

                                      return const SymptomScreen();

                                    },

                                  ),

                                );

                              },

                            ),

                            _actionCard(

                              title:
                                  'Daily Notes',

                              icon:
                                  Icons.edit_note,

                              color:
                                  Colors.orange,

                              onTap: () {

                                Navigator.push(

                                  context,

                                  MaterialPageRoute(

                                    builder: (_) {

                                      return const AddNoteScreen();

                                    },

                                  ),

                                );

                              },

                            ),

                            _actionCard(

                              title:
                                  'Reports',

                              icon:
                                  Icons.analytics,

                              color:
                                  Colors.purple,

                              onTap: () {

                                Navigator.push(

                                  context,

                                  MaterialPageRoute(

                                    builder: (_) {

                                      return const ReportScreen();

                                    },

                                  ),

                                );

                              },

                            ),

                          ],

                        ),

                      ],

                    ),

                  ),

                ),

    );

  }

  // ======================================================
  // ACTION CARD
  // ======================================================

  Widget _actionCard({

    required String title,

    required IconData icon,

    required Color color,

    required VoidCallback onTap,

  }) {

    return InkWell(

      borderRadius:
          BorderRadius.circular(24),

      onTap: onTap,

      child: Container(

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
              BorderRadius.circular(24),

          boxShadow: [

            BoxShadow(

              color:
                  Colors.black.withOpacity(0.04),

              blurRadius: 10,

              offset:
                  const Offset(0, 5),

            ),

          ],

        ),

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Container(

              padding:
                  const EdgeInsets.all(16),

              decoration:
                  BoxDecoration(

                color:
                    color.withOpacity(0.1),

                shape:
                    BoxShape.circle,

              ),

              child: Icon(

                icon,

                color: color,

                size: 32,

              ),

            ),

            const SizedBox(height: 16),

            Text(

              title,

              style:
                  const TextStyle(

                fontWeight:
                    FontWeight.bold,

              ),

            ),

          ],

        ),

      ),

    );

  }

}