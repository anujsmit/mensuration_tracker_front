import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../providers/health_profile_provider.dart';
import 'package:mensurationhealthapp/core/theme/app_theme.dart';

import 'edit_profile_screen.dart';
import 'health_profile_screen.dart';
import 'complete_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isChecking = true;
  bool _hasCompleteData = false;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkProfileAndNavigate();
    });
  }

  Future<void> _checkProfileAndNavigate() async {
    final profileProvider = context.read<ProfileProvider>();
    final healthProvider = context.read<HealthProfileProvider>();

    // Fetch both profiles
    await Future.wait([
      profileProvider.fetchProfile(),
      healthProvider.fetchHealthProfile(),
    ]);

    if (!mounted) return;

    final profile = profileProvider.profile;
    final health = healthProvider.healthProfile;

    // Debug prints
    print('=== PROFILE CHECK ===');
    print('Profile exists: ${profile != null}');
    print('Profile fullName: ${profile?.fullName}');
    print('Health exists: ${health != null}');
    print('Health lastPeriodDate: ${health?.lastPeriodDate}');
    print('Health cycleLength: ${health?.cycleLength}');
    print('=====================');

    // Check if data exists
    final hasName = profile != null && 
                    profile.fullName != null && 
                    profile.fullName!.trim().isNotEmpty;
    
    final hasHealthData = health != null &&
                          health.lastPeriodDate != null &&
                          health.cycleLength != null &&
                          health.cycleLength! > 0;

    // If data exists, stay on profile screen
    if (hasName && hasHealthData) {
      print('✅ Profile data exists - staying on ProfileScreen');
      setState(() {
        _hasCompleteData = true;
        _isChecking = false;
      });
    } else {
      print('⚠️ Missing data - showing CompleteProfileScreen');
      setState(() {
        _isChecking = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CompleteProfileScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileProvider = context.watch<ProfileProvider>();
    final healthProvider = context.watch<HealthProfileProvider>();

    final profile = profileProvider.profile;
    final health = healthProvider.healthProfile;
    final nextPeriod = healthProvider.nextPredictedPeriod;
    final ovulation = healthProvider.predictedOvulation;

    // Show loading while checking
    if (_isChecking || profileProvider.isLoading || healthProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If no complete data, don't build (navigation will happen)
    if (!_hasCompleteData) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'My Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: theme.colorScheme.onSurface),
            onPressed: () => _showSettingsMenu(theme),
          ),
        ],
      ),
      body: profile == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Profile not found',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CompleteProfileScreen(),
                        ),
                      );
                    },
                    child: const Text('Create Profile'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Header
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.primaryColor,
                              theme.colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      Positioned(
                        top: 60,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 70,
                              backgroundColor: theme.cardColor,
                              backgroundImage: profile.avatarUrl != null
                                  ? NetworkImage(profile.avatarUrl!)
                                  : null,
                              child: profile.avatarUrl == null
                                  ? Icon(
                                      Icons.person,
                                      size: 70,
                                      color: theme.primaryColor,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 80),
                  
                  Text(
                    profile.fullName ?? 'Unknown User',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Menstrual Health Tracker',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.edit, size: 20),
                          label: const Text('Edit Profile'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            ).then((_) {
                              profileProvider.fetchProfile();
                              healthProvider.fetchHealthProfile();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.favorite, size: 20),
                          label: const Text('Health Profile'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HealthProfileScreen(),
                              ),
                            ).then((_) {
                              healthProvider.fetchHealthProfile();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Stats Section
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Health Statistics',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Cycle Length Card
                  _buildStatCard(
                    context: context,
                    title: 'Cycle Length',
                    value: '${health?.cycleLength ?? 28} days',
                    icon: Icons.calendar_today,
                    subtitle: 'Average cycle duration',
                    color: Colors.purple,
                  ),
                  
                  // Bleeding Duration Card
                  _buildStatCard(
                    context: context,
                    title: 'Bleeding Duration',
                    value: '${health?.bleedingDuration ?? 5} days',
                    icon: Icons.water_drop,
                    subtitle: 'Typical period length',
                    color: Colors.red,
                  ),
                  
                  // Flow Regularity Card
                  _buildStatCard(
                    context: context,
                    title: 'Flow Regularity',
                    value: _formatRegularity(health?.flowRegularity),
                    icon: Icons.timeline,
                    subtitle: 'Cycle consistency',
                    color: Colors.orange,
                  ),
                  
                  // Next Period Card
                  _buildStatCard(
                    context: context,
                    title: 'Next Period',
                    value: nextPeriod != null
                        ? DateFormat('MMM d, yyyy').format(nextPeriod)
                        : 'Not enough data',
                    icon: Icons.event,
                    subtitle: _getDaysUntil(nextPeriod),
                    color: Colors.pink,
                  ),
                  
                  // Ovulation Card
                  _buildStatCard(
                    context: context,
                    title: 'Ovulation',
                    value: ovulation != null
                        ? DateFormat('MMM d, yyyy').format(ovulation)
                        : 'Not enough data',
                    icon: Icons.favorite,
                    subtitle: 'Fertile window',
                    color: Colors.teal,
                  ),
                  
                  // Cycle Day Card
                  _buildStatCard(
                    context: context,
                    title: 'Current Cycle Day',
                    value: _getCurrentCycleDay(health),
                    icon: Icons.today,
                    subtitle: 'Day of your cycle',
                    color: Colors.indigo,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Recent Activity
                  if (health?.lastPeriodDate != null) ...[
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Recent Activity',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildActivityItem(
                            context: context,
                            icon: Icons.date_range,
                            title: 'Last Period',
                            date: health!.lastPeriodDate!,
                            color: Colors.pink,
                          ),
                          const Divider(),
                          _buildActivityItem(
                            context: context,
                            icon: Icons.calendar_month,
                            title: 'Next Predicted Period',
                            date: nextPeriod,
                            color: Colors.purple,
                          ),
                          if (ovulation != null) ...[
                            const Divider(),
                            _buildActivityItem(
                              context: context,
                              icon: Icons.favorite,
                              title: 'Predicted Ovulation',
                              date: ovulation,
                              color: Colors.teal,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  void _showSettingsMenu(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.notifications, color: theme.primaryColor),
                title: const Text('Notifications'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.language, color: theme.primaryColor),
                title: const Text('Language'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.privacy_tip, color: theme.primaryColor),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required DateTime? date,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: theme.textTheme.bodyLarge),
          ),
          Text(
            date != null ? DateFormat('MMM d, yyyy').format(date) : 'Not set',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatRegularity(String? regularity) {
    switch (regularity) {
      case 'regular': return 'Regular';
      case 'usually_regular': return 'Usually Regular';
      case 'usually_irregular': return 'Usually Irregular';
      case 'always_irregular': return 'Always Irregular';
      default: return 'Not specified';
    }
  }

  String _getDaysUntil(DateTime? date) {
    if (date == null) return 'Not enough data';
    final difference = date.difference(DateTime.now()).inDays;
    if (difference < 0) return 'Past due';
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    return 'In $difference days';
  }

  String _getCurrentCycleDay(dynamic health) {
    if (health?.lastPeriodDate == null) return 'Not enough data';
    final daysSince = DateTime.now().difference(health.lastPeriodDate!).inDays;
    final cycleLength = health.cycleLength ?? 28;
    if (daysSince < 0) return 'Not enough data';
    if (daysSince > cycleLength) return 'Late period';
    return 'Day ${daysSince + 1} of $cycleLength';
  }
}