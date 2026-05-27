import 'package:flutter/material.dart';
import 'package:mensurationhealthapp/features/chat/screens/chat_screen.dart';
import 'package:mensurationhealthapp/features/cycles/services/pads_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// ======================================================
// PROVIDERS
// ======================================================

import '../../features/auth/providers/auth_provider.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../../features/profile/providers/health_profile_provider.dart';

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
import '../../features/profile/screens/complete_profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _isCheckingProfile = true;

  final List<Widget> _screens = [
    const HomeDashboard(),
    const CycleHistoryScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkProfileAndNavigate();
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
    print('=== MAIN NAVIGATION PROFILE CHECK ===');
    print('Profile exists: ${profile != null}');
    print('Profile fullName: ${profile?.fullName}');
    print('Health exists: ${health != null}');
    print('Health lastPeriodDate: ${health?.lastPeriodDate}');
    print('Health cycleLength: ${health?.cycleLength}');
    print('======================================');

    // Check if data exists
    final hasName = profile != null && 
                    profile.fullName != null && 
                    profile.fullName!.trim().isNotEmpty;
    
    final hasHealthData = health != null &&
                          health.lastPeriodDate != null &&
                          health.cycleLength != null &&
                          health.cycleLength! > 0;

    // If data exists, show main app, otherwise show complete profile
    if (!hasName || !hasHealthData) {
      print('⚠️ Missing data - redirecting to CompleteProfileScreen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CompleteProfileScreen(),
        ),
      );
    } else {
      print('✅ Profile data exists - showing MainNavigationScreen');
      setState(() {
        _isCheckingProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking profile
    if (_isCheckingProfile) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C63FF),
        onPressed: _showBottomSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Cycles'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _bottomTile(
                  icon: Icons.water_drop,
                  title: 'Track Cycle',
                  color: const Color(0xFF6C63FF),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddCycleScreen()));
                  },
                ),
                _bottomTile(
                  icon: Icons.chat_bubble_outline,
                  title: 'AI Assistant',
                  color: const Color(0xFF6C63FF),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatScreen()),
                    );
                  },
                ),
                _bottomTile(
                  icon: Icons.favorite,
                  title: 'Track Symptoms',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SymptomScreen()));
                  },
                ),
                _bottomTile(
                  icon: Icons.edit_note,
                  title: 'Daily Note',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddNoteScreen()));
                  },
                ),
                _bottomTile(
                  icon: Icons.analytics,
                  title: 'View Reports',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ReportScreen()));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bottomTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

// ======================================================
// HOME DASHBOARD WITH PRODUCT USAGE
// ======================================================

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<String>> _calendarNotes = {};

  // Product usage data
  Map<String, dynamic> _productUsage = {
    'totalPads': 0,
    'totalTampons': 0,
    'totalLiners': 0,
    'averagePerDay': 0,
    'flowDistribution': {
      'light': 0,
      'medium': 0,
      'heavy': 0,
      'very_heavy': 0,
    },
  };
  bool _loadingProducts = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      context.read<ProfileProvider>().fetchProfile(),
      context.read<HealthProfileProvider>().fetchHealthProfile(),
      _loadProductUsage(),
    ]);
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _loadProductUsage() async {
    setState(() => _loadingProducts = true);
    try {
      final padsService = PadsService();
      final stats = await padsService.getStatistics(days: 30);
      setState(() {
        _productUsage = {
          'totalPads': stats.totalPads,
          'totalTampons': stats.totalTampons,
          'totalLiners': stats.totalLiners,
          'averagePerDay': stats.averagePerDay,
          'flowDistribution': stats.flowIntensityCount,
        };
        _loadingProducts = false;
      });
    } catch (e) {
      print('Error loading product usage: $e');
      setState(() => _loadingProducts = false);
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  List<String> _getNotesForDay(DateTime day) {
    final normalized = DateTime.utc(day.year, day.month, day.day);
    return _calendarNotes[normalized] ?? [];
  }

  void _showDayNotesModal(DateTime day) {
    final controller = TextEditingController();
    final notes = _getNotesForDay(day);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('MMM d, yyyy').format(day),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ...notes.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text("• $e"))),
              TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Add note...')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF)),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      setState(() {
                        final normalized =
                            DateTime.utc(day.year, day.month, day.day);
                        _calendarNotes.putIfAbsent(normalized, () => []);
                        _calendarNotes[normalized]!.add(controller.text.trim());
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save Note',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileProvider = context.watch<ProfileProvider>();
    final healthProvider = context.watch<HealthProfileProvider>();
    final profile = profileProvider.profile;
    final health = healthProvider.healthProfile;
    final user = supabase.auth.currentUser;
    final nextPeriod = healthProvider.nextPredictedPeriod;
    final daysUntilPeriod = nextPeriod != null
        ? nextPeriod.difference(DateTime.now()).inDays
        : null;
    final currentCycleDay = _getCurrentCycleDay(health);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'CycleTrack',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 24),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final parentState =
                  context.findAncestorStateOfType<_MainNavigationScreenState>();
              parentState?.setState(() => parentState._currentIndex = 3);
            },
            icon: const Icon(Icons.person_outline, color: Colors.black87),
          ),
          IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout_outlined, color: Colors.black87)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<ProfileProvider>().fetchProfile(),
            context.read<HealthProfileProvider>().fetchHealthProfile(),
            _loadProductUsage(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Prediction Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.pink.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10)),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(Icons.calendar_today,
                                    color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                daysUntilPeriod != null && daysUntilPeriod <= 7
                                    ? 'Period Coming Soon!'
                                    : 'Cycle Status',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            daysUntilPeriod != null
                                ? daysUntilPeriod == 0
                                    ? 'Period Today'
                                    : daysUntilPeriod == 1
                                        ? 'Period Tomorrow'
                                        : 'Period in $daysUntilPeriod days'
                                : 'Add cycle data to get predictions',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            daysUntilPeriod != null && daysUntilPeriod <= 7
                                ? 'Prepare for your upcoming period'
                                : 'Your cycle is on track',
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.8)),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _buildPredictionChip(
                                icon: Icons.water_drop,
                                label: currentCycleDay != '--'
                                    ? 'Day $currentCycleDay'
                                    : 'No data',
                              ),
                              const SizedBox(width: 12),
                              _buildPredictionChip(
                                icon: Icons.calendar_month,
                                label: daysUntilPeriod != null &&
                                        daysUntilPeriod > 0
                                    ? '${daysUntilPeriod}d left'
                                    : 'Tracking',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildQuickStat(
                      title: 'Cycle Day',
                      value: currentCycleDay != '--' ? currentCycleDay : '--',
                      subtitle: 'of ${health?.cycleLength ?? 28} days',
                      icon: Icons.today,
                      color: const Color(0xFF6C63FF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickStat(
                      title: 'Next Period',
                      value: daysUntilPeriod != null && daysUntilPeriod >= 0
                          ? daysUntilPeriod == 0
                              ? 'Today'
                              : daysUntilPeriod == 1
                                  ? 'Tomorrow'
                                  : '$daysUntilPeriod d'
                          : '--',
                      subtitle: daysUntilPeriod != null && daysUntilPeriod > 1
                          ? 'remaining'
                          : '',
                      icon: Icons.event,
                      color: const Color(0xFFFF6584),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickStat(
                      title: 'Cycle Length',
                      value: '${health?.cycleLength ?? 28}',
                      subtitle: 'days avg',
                      icon: Icons.timeline,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Product Usage Card
              if (!_loadingProducts &&
                  (_productUsage['totalPads'] > 0 ||
                      _productUsage['totalTampons'] > 0))
                _buildProductUsageCard(theme),

              if (!_loadingProducts &&
                  (_productUsage['totalPads'] > 0 ||
                      _productUsage['totalTampons'] > 0))
                const SizedBox(height: 24),

              // Upcoming Phases
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 10)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Upcoming Phases',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPhaseCard(
                            'Menstrual',
                            'Days 1-5',
                            Icons.water_drop,
                            Colors.red,
                            currentCycleDay != '--' &&
                                int.parse(currentCycleDay) <= 5),
                        _buildPhaseCard(
                            'Follicular',
                            'Days 6-14',
                            Icons.energy_savings_leaf,
                            Colors.orange,
                            currentCycleDay != '--' &&
                                int.parse(currentCycleDay) > 5 &&
                                int.parse(currentCycleDay) <= 14),
                        _buildPhaseCard(
                            'Ovulation',
                            'Days 15-16',
                            Icons.favorite,
                            Colors.teal,
                            currentCycleDay != '--' &&
                                int.parse(currentCycleDay) > 14 &&
                                int.parse(currentCycleDay) <= 16),
                        _buildPhaseCard(
                            'Luteal',
                            'Days 17-28',
                            Icons.bedtime,
                            Colors.purple,
                            currentCycleDay != '--' &&
                                int.parse(currentCycleDay) > 16),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Cycle Progress Bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 10)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Cycle Progress',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFF6C63FF), Color(0xFFFF6584)]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            currentCycleDay != '--'
                                ? 'Day $currentCycleDay'
                                : 'No Data',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: currentCycleDay != '--'
                            ? int.parse(currentCycleDay) /
                                (health?.cycleLength ?? 28)
                            : 0,
                        backgroundColor: Colors.grey.shade200,
                        minHeight: 10,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6C63FF)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Start',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12)),
                        Text(
                            '${((int.parse(currentCycleDay != '--' ? currentCycleDay : '0') / (health?.cycleLength ?? 28)) * 100).toInt()}%',
                            style: const TextStyle(
                                color: Color(0xFFFF6584),
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        Text('End',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Calendar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 10)
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getNotesForDay,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                        shape: BoxShape.circle),
                    selectedDecoration: const BoxDecoration(
                        color: Color(0xFF6C63FF), shape: BoxShape.circle),
                    weekendTextStyle: const TextStyle(color: Colors.red),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _showDayNotesModal(selectedDay);
                  },
                  onFormatChanged: (format) {
                    setState(() => _calendarFormat = format);
                  },
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================
  // PRODUCT USAGE CARD
  // ======================================================

  Widget _buildProductUsageCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal.withOpacity(0.05),
            Colors.blue.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.teal.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.inventory, color: Colors.teal, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Product Usage (Last 30 Days)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildUsageStatItem('Pads', _productUsage['totalPads'],
                  Icons.water_drop, Colors.pink),
              _buildUsageStatItem('Tampons', _productUsage['totalTampons'],
                  Icons.water, Colors.purple),
              _buildUsageStatItem('Liners', _productUsage['totalLiners'],
                  Icons.water_drop_outlined, Colors.teal),
            ],
          ),

          if (_productUsage['averagePerDay'] > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.show_chart, size: 16, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(
                    'Average ${_productUsage['averagePerDay']} products per day',
                    style: TextStyle(
                        color: Colors.teal[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUsageStatItem(
      String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // ======================================================
  // HELPER METHODS
  // ======================================================

  Widget _buildPredictionChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildQuickStat({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          if (subtitle.isNotEmpty)
            Text(subtitle,
                style: TextStyle(color: Colors.grey[400], fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildPhaseCard(
      String phase, String days, IconData icon, Color color, bool isActive) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.1) : Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isActive ? color : Colors.grey, size: 24),
        ),
        const SizedBox(height: 6),
        Text(phase,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? color : Colors.grey)),
        Text(days, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
      ],
    );
  }

  String _getCurrentCycleDay(dynamic health) {
    if (health?.lastPeriodDate == null) return '--';
    final daysSince = DateTime.now().difference(health.lastPeriodDate!).inDays;
    final cycleLength = health.cycleLength ?? 28;
    if (daysSince < 0 || daysSince > cycleLength) return '--';
    return '${daysSince + 1}';
  }
}