// lib/screens/home/home.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mensurationhealthapp/providers/auth_provider.dart';
import 'package:mensurationhealthapp/providers/profile_provider.dart';
import 'package:mensurationhealthapp/screens/auth/login_screen.dart';
import 'package:mensurationhealthapp/screens/home/profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  final supabase =
      Supabase.instance.client;

  Map<String, dynamic>? profile;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ==========================================
  // LOAD USER DATA
  // ==========================================

  Future<void> _loadData() async {
    try {
      final authProvider =
          Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      final profileProvider =
          Provider.of<ProfileProvider>(
        context,
        listen: false,
      );

      final user =
          supabase.auth.currentUser;

      if (user == null) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const LoginScreen(),
          ),
        );

        return;
      }

      await profileProvider
          .fetchProfile(
        user.id,
        '',
      );

      setState(() {
        profile =
            profileProvider.profile;
        isLoading = false;
      });

    } catch (e) {
      debugPrint(
        'Home load error: $e',
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  // ==========================================
  // LOGOUT
  // ==========================================

  Future<void> _logout() async {
    try {
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
          builder: (_) =>
              const LoginScreen(),
        ),
        (route) => false,
      );

    } catch (e) {
      debugPrint(
        'Logout error: $e',
      );
    }
  }

  // ==========================================
  // CALCULATE NEXT PERIOD
  // ==========================================

  String calculateNextPeriod() {
    try {
      if (profile == null) {
        return '--';
      }

      final lastPeriod =
          profile![
              'last_period_date'];

      final cycleLength =
          profile![
                  'cycle_length'] ??
              28;

      if (lastPeriod == null) {
        return '--';
      }

      final lastDate =
          DateTime.parse(
        lastPeriod.toString(),
      );

      final nextDate =
          lastDate.add(
        Duration(
          days: cycleLength,
        ),
      );

      return
          '${nextDate.day}/${nextDate.month}/${nextDate.year}';

    } catch (e) {
      return '--';
    }
  }

  // ==========================================
  // DAYS LEFT
  // ==========================================

  int calculateDaysLeft() {
    try {
      if (profile == null) {
        return 0;
      }

      final lastPeriod =
          profile![
              'last_period_date'];

      final cycleLength =
          profile![
                  'cycle_length'] ??
              28;

      if (lastPeriod == null) {
        return 0;
      }

      final lastDate =
          DateTime.parse(
        lastPeriod.toString(),
      );

      final nextDate =
          lastDate.add(
        Duration(
          days: cycleLength,
        ),
      );

      return nextDate
          .difference(
            DateTime.now(),
          )
          .inDays;

    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primaryColor =
        theme.colorScheme.primary;

    final authProvider =
        Provider.of<AuthProvider>(
      context,
    );

    final user =
        supabase.auth.currentUser;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            Colors.transparent,

        title: const Text(
          'Menstrual Health',
        ),

        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ProfilePage(),
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

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadData,

              child:
                  SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding:
                    const EdgeInsets.all(
                        20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    // ==========================
                    // HEADER
                    // ==========================

                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets
                              .all(24),

                      decoration:
                          BoxDecoration(
                        gradient:
                            LinearGradient(
                          colors: [
                            primaryColor,
                            primaryColor
                                .withOpacity(
                                    0.7),
                          ],
                        ),

                        borderRadius:
                            BorderRadius.circular(
                                28),
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          Text(
                            'Hello 👋',

                            style:
                                TextStyle(
                              color: Colors
                                  .white
                                  .withOpacity(
                                      0.9),

                              fontSize:
                                  18,
                            ),
                          ),

                          const SizedBox(
                              height: 8),

                          Text(
                            profile?[
                                    'full_name'] ??
                                user?.email ??
                                'User',

                            style:
                                const TextStyle(
                              color:
                                  Colors
                                      .white,

                              fontSize:
                                  28,

                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                              height: 20),

                          Container(
                            padding:
                                const EdgeInsets
                                    .all(
                                        16),

                            decoration:
                                BoxDecoration(
                              color: Colors
                                  .white
                                  .withOpacity(
                                      0.15),

                              borderRadius:
                                  BorderRadius.circular(
                                      20),
                            ),

                            child: Row(
                              children: [
                                const Icon(
                                  Icons
                                      .favorite,

                                  color: Colors
                                      .white,

                                  size: 30,
                                ),

                                const SizedBox(
                                    width:
                                        14),

                                Expanded(
                                  child:
                                      Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [
                                      const Text(
                                        'Next Period',

                                        style:
                                            TextStyle(
                                          color:
                                              Colors.white70,
                                        ),
                                      ),

                                      const SizedBox(
                                          height:
                                              4),

                                      Text(
                                        calculateNextPeriod(),

                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,

                                          fontSize:
                                              20,

                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                        height: 28),

                    // ==========================
                    // STATS
                    // ==========================

                    Row(
                      children: [
                        Expanded(
                          child:
                              _buildStatCard(
                            title:
                                'Cycle Length',

                            value:
                                '${profile?['cycle_length'] ?? 28} days',

                            icon:
                                Icons.calendar_month,

                            color:
                                Colors.pink,
                          ),
                        ),

                        const SizedBox(
                            width: 16),

                        Expanded(
                          child:
                              _buildStatCard(
                            title:
                                'Days Left',

                            value:
                                '${calculateDaysLeft()}',

                            icon:
                                Icons.timelapse,

                            color:
                                Colors.purple,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 28),

                    // ==========================
                    // HEALTH SUMMARY
                    // ==========================

                    Text(
                      'Health Summary',

                      style: theme
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                        height: 16),

                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets
                              .all(20),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                                24),

                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .black
                                .withOpacity(
                                    0.04),

                            blurRadius:
                                10,

                            offset:
                                const Offset(
                                    0, 5),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          _buildInfoRow(
                            'Age',
                            '${profile?['age'] ?? '--'}',
                          ),

                          _buildInfoRow(
                            'Weight',
                            '${profile?['weight'] ?? '--'} kg',
                          ),

                          _buildInfoRow(
                            'Height',
                            '${profile?['height'] ?? '--'} cm',
                          ),

                          _buildInfoRow(
                            'Flow Amount',
                            '${profile?['flow_amount'] ?? '--'}',
                          ),

                          _buildInfoRow(
                            'Regularity',
                            '${profile?['flow_regularity'] ?? '--'}',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                        height: 28),

                    // ==========================
                    // QUICK ACTIONS
                    // ==========================

                    Text(
                      'Quick Actions',

                      style: theme
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                        height: 16),

                    GridView.count(
                      crossAxisCount: 2,

                      shrinkWrap: true,

                      physics:
                          const NeverScrollableScrollPhysics(),

                      crossAxisSpacing:
                          16,

                      mainAxisSpacing:
                          16,

                      childAspectRatio:
                          1.15,

                      children: [
                        _buildActionCard(
                          title:
                              'Profile',

                          icon:
                              Icons.person,

                          color:
                              Colors.blue,

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ProfilePage(),
                              ),
                            );
                          },
                        ),

                        _buildActionCard(
                          title:
                              'Track Cycle',

                          icon:
                              Icons.favorite,

                          color:
                              Colors.pink,

                          onTap: () {},
                        ),

                        _buildActionCard(
                          title:
                              'Symptoms',

                          icon:
                              Icons.health_and_safety,

                          color:
                              Colors.green,

                          onTap: () {},
                        ),

                        _buildActionCard(
                          title:
                              'Reports',

                          icon:
                              Icons.analytics,

                          color:
                              Colors.orange,

                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  // ==========================================
  // STAT CARD
  // ==========================================

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.04),

            blurRadius: 10,

            offset:
                const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Container(
            padding:
                const EdgeInsets.all(
                    10),

            decoration: BoxDecoration(
              color:
                  color.withOpacity(0.1),

              borderRadius:
                  BorderRadius.circular(
                      14),
            ),

            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            title,

            style: TextStyle(
              color:
                  Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value,

            style:
                const TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // INFO ROW
  // ==========================================

  Widget _buildInfoRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 12,
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

        children: [
          Text(
            label,

            style: TextStyle(
              color:
                  Colors.grey.shade700,
            ),
          ),

          Text(
            value,

            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ACTION CARD
  // ==========================================

  Widget _buildActionCard({
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
              BorderRadius.circular(
                  24),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.04),

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
                  const EdgeInsets.all(
                      16),

              decoration:
                  BoxDecoration(
                color: color
                    .withOpacity(0.1),

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