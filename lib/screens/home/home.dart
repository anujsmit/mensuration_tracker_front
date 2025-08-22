import 'package:flutter/material.dart';
import 'package:mensurationhealthapp/providers/auth_provider.dart';
import 'package:mensurationhealthapp/screens/home/profile.dart';
import 'package:provider/provider.dart';
import 'package:mensurationhealthapp/providers/profile_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final VoidCallback? onProfileTabRequested;

  const HomePage({super.key, this.onProfileTabRequested});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadCalendarData();
  }

  void _loadCalendarData() {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    if (authProvider.isAuth && authProvider.token != null) {
      _fetchCalendarData(authProvider.token!);
    }
  }

  Future<void> _fetchCalendarData(String token) async {
    try {
      final now = DateTime.now();
      final response = await http.get(
        Uri.parse('http://10.68.147.188:3000/api/auth/profile/calendar?year=${now.year}&month=${now.month.toString().padLeft(2, '0')}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Calendar data loaded: $data');
      }
    } catch (error) {
      print('Error loading calendar data: $error');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchNotesForDate(DateTime date, String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.68.147.188:3000/api/auth/profile/notes?date=${DateFormat('yyyy-MM-dd').format(date)}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      return [];
    } catch (error) {
      print('Error fetching notes: $error');
      return [];
    }
  }

  void _showAddNoteDialog(BuildContext context, DateTime selectedDay, ProfileProvider profileProvider) async {
    final authProvider = context.read<AuthProvider>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    TextEditingController noteController = TextEditingController();
    String? selectedMood;
    bool isEditing = false;
    String? noteId;
    List<Map<String, dynamic>> previousNotes = [];

    // Fetch existing notes for the selected date
    previousNotes = await _fetchNotesForDate(selectedDay, authProvider.token!);
    Map<String, dynamic>? currentNote = previousNotes.isNotEmpty ? previousNotes.first : null;

    if (currentNote != null) {
      isEditing = true;
      noteId = currentNote['id']?.toString();
      noteController.text = currentNote['content'] ?? '';
      selectedMood = currentNote['mood'];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isEditing
              ? 'Edit Note for ${DateFormat('MMM dd, yyyy').format(selectedDay)}'
              : 'Add Note for ${DateFormat('MMM dd, yyyy').format(selectedDay)}',
          style: theme.textTheme.titleLarge,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedMood,
                decoration: InputDecoration(
                  labelText: 'Mood',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  'Happy',
                  'Sad',
                  'Anxious',
                  'Energetic',
                  'Tired',
                  'Normal',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedMood = value;
                },
              ),
              if (previousNotes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Previous Notes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                ...previousNotes.map((note) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.outline.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Note: ${note['content'] ?? 'No content'}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurface.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Mood: ${note['mood'] ?? 'Not set'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurface.withOpacity(0.6),
                              ),
                            ),
                            if (note['updated_at'] != null)
                              Text(
                                'Updated: ${DateFormat('MMM dd, yyyy, hh:mm a').format(DateTime.parse(note['updated_at']))}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurface.withOpacity(0.6),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final url = isEditing
                    ? 'http://10.68.147.188:3000/api/auth/profile/notes/$noteId'
                    : 'http://10.68.147.188:3000/api/auth/profile/notes';
                final method = isEditing ? http.put : http.post;

                final response = await method(
                  Uri.parse(url),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer ${authProvider.token}',
                  },
                  body: json.encode({
                    'date': DateFormat('yyyy-MM-dd').format(selectedDay),
                    'content': noteController.text,
                    'mood': selectedMood,
                  }),
                );

                if (response.statusCode == 200 || response.statusCode == 201) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'Note updated successfully' : 'Note saved successfully'),
                      backgroundColor: colors.primary,
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error ${isEditing ? 'updating' : 'saving'} note'),
                      backgroundColor: colors.error,
                    ),
                  );
                }
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error ${isEditing ? 'updating' : 'saving'} note: $error'),
                    backgroundColor: colors.error,
                  ),
                );
              }
            },
            child: Text(isEditing ? 'Update' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final now = DateTime.now();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (!authProvider.isAuth) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: colors.primary),
        ),
      );
    }

    if (profileProvider.isLoading && profileProvider.profile == null) {
      return Scaffold(
        backgroundColor: colors.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colors.primary),
              const SizedBox(height: 20),
              Text(
                'Loading your cycle data...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (profileProvider.error.isNotEmpty) {
      return Scaffold(
        backgroundColor: colors.surface,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: colors.error,
                ),
                const SizedBox(height: 20),
                Text(
                  'Error loading data',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.error,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  profileProvider.error,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                  onPressed: () => profileProvider.fetchProfile(
                    authProvider.userId!,
                    authProvider.token!,
                  ),
                  child: Text(
                    'Try Again',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (profileProvider.profile == null) {
      return Scaffold(
        backgroundColor: colors.surface,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 48,
                  color: colors.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Complete your profile',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'We need some information to provide personalized insights',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                  onPressed: () {
                    if (widget.onProfileTabRequested != null) {
                      widget.onProfileTabRequested!();
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => const ProfilePage()),
                      );
                    }
                  },
                  child: Text(
                    'Set Up Profile',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final cycleData = _calculateCycleData(profileProvider, now);

    return Scaffold(
      backgroundColor: colors.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          profileProvider.fetchProfile(
              authProvider.userId!, authProvider.token!);
          _loadCalendarData();
        },
        color: colors.primary,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  FadeInDown(child: _buildWelcomeCard(context, theme)),
                  const SizedBox(height: 20),
                  FadeInUp(child: _buildCycleCountdownSection(cycleData, theme)),
                  const SizedBox(height: 20),
                  FadeInUp(child: _buildCycleOverview(cycleData, theme)),
                  const SizedBox(height: 20),
                  FadeInUp(child: _buildCalendarSection(profileProvider, theme)),
                  const SizedBox(height: 20),
                  FadeInUp(child: _buildCyclePhasesSection(cycleData, theme)),
                  const SizedBox(height: 20),
                  FadeInUp(
                      child: _buildFertilityDetailsSection(cycleData, theme)),
                  const SizedBox(height: 20),
                  FadeInUp(
                      child: _buildHealthSummarySection(
                          profileProvider, theme)),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, ThemeData theme) {
    final authProvider = context.watch<AuthProvider>();
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: colors.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    colors.primary,
                    colors.primaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                size: 30,
                color: colors.onPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, ${authProvider.username ?? 'there'}!",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMMM d').format(DateTime.now()),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleCountdownSection(CycleData data, ThemeData theme) {
    final colors = theme.colorScheme;
    final daysUntilNextPeriod = data.cycleLength - data.currentDay;
    final daysUntilFertile = data.fertileWindowStartDay - data.currentDay;
    final isFertile = data.currentDay >= data.fertileWindowStartDay && 
                      data.currentDay <= data.fertileWindowEndDay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Cycle Countdown",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: colors.surfaceVariant,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildCountdownItem(
                  icon: Icons.water_drop,
                  label: "Next Period",
                  days: daysUntilNextPeriod,
                  date: data.nextPeriodDate,
                  color: colors.primary,
                  theme: theme,
                ),
                const Divider(height: 20),
                if (isFertile)
                  _buildCountdownItem(
                    icon: Icons.favorite,
                    label: "Fertile Window Ends",
                    days: data.fertileWindowEndDay - data.currentDay,
                    color: colors.secondary,
                    theme: theme,
                  )
                else
                  _buildCountdownItem(
                    icon: Icons.favorite,
                    label: "Next Fertile Window",
                    days: daysUntilFertile,
                    color: colors.secondary,
                    theme: theme,
                  ),
                const Divider(height: 20),
                _buildCountdownItem(
                  icon: Icons.egg,
                  label: "Next Ovulation",
                  days: data.ovulationDay > data.currentDay 
                      ? data.ovulationDay - data.currentDay 
                      : (data.cycleLength - data.currentDay) + data.ovulationDay,
                  color: colors.tertiary,
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownItem({
    required IconData icon,
    required String label,
    required int days,
    String? date,
    required Color color,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              if (date != null)
                Text(
                  date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "$days ${days == 1 ? 'day' : 'days'}",
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCycleOverview(CycleData data, ThemeData theme) {
    final colors = theme.colorScheme;
    final isFertile = data.currentDay >= data.fertileWindowStartDay &&
        data.currentDay <= data.fertileWindowEndDay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Cycle Overview",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: colors.surfaceVariant,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sections: _buildPieChartSections(data, colors),
                          centerSpaceRadius: 50,
                          sectionsSpace: 0,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Day ${data.currentDay}",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          Text(
                            "of ${data.cycleLength}",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getPhaseColor(data.phase, colors).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getPhaseColor(data.phase, colors).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    data.phase,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _getPhaseColor(data.phase, colors),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCycleStat(
                      icon: Icons.calendar_today,
                      label: "Next Period",
                      value: data.nextPeriodDate,
                      theme: theme,
                    ),
                    _buildCycleStat(
                      icon: Icons.water_drop,
                      label: "Last Period",
                      value: data.lastPeriodDate ?? "Not recorded",
                      theme: theme,
                    ),
                  ],
                ),
                if (isFertile) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.secondary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.favorite, color: colors.secondary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Conception chance: ${_getConceptionProbability(data.currentDay, data.ovulationDay)}%",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
      CycleData data, ColorScheme colors) {
    return [
      PieChartSectionData(
        color: _getPhaseColor("Menstruation", colors),
        value: data.periodLength.toDouble(),
        title: '',
        radius: data.currentDay <= data.periodLength ? 45 : 35,
        showTitle: false,
      ),
      PieChartSectionData(
        color: _getPhaseColor("Follicular Phase", colors),
        value: (data.fertileWindowStartDay - data.periodLength - 1).toDouble(),
        title: '',
        radius: data.currentDay > data.periodLength &&
                data.currentDay < data.fertileWindowStartDay
            ? 45
            : 35,
        showTitle: false,
      ),
      PieChartSectionData(
        color: _getPhaseColor("Fertile Window", colors),
        value: (data.fertileWindowEndDay - data.fertileWindowStartDay + 1)
            .toDouble(),
        title: '',
        radius: data.currentDay >= data.fertileWindowStartDay &&
                data.currentDay <= data.fertileWindowEndDay
            ? 45
            : 35,
        showTitle: false,
      ),
      PieChartSectionData(
        color: _getPhaseColor("Luteal Phase", colors),
        value: (data.cycleLength - data.fertileWindowEndDay).toDouble(),
        title: '',
        radius: data.currentDay > data.fertileWindowEndDay ? 45 : 35,
        showTitle: false,
      ),
    ];
  }

  Widget _buildCycleStat({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarSection(ProfileProvider profileProvider, ThemeData theme) {
    final colors = theme.colorScheme;
    final cycleData = _calculateCycleData(profileProvider, DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Cycle Calendar",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: colors.surfaceVariant,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _showAddNoteDialog(context, selectedDay, profileProvider);
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: colors.secondary,
                      shape: BoxShape.circle,
                    ),
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  eventLoader: (day) {
                    return _getEventsForDay(day, cycleData);
                  },
                ),
                const SizedBox(height: 16),
                _buildCalendarLegend(theme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<dynamic> _getEventsForDay(DateTime day, CycleData cycleData) {
    final events = <dynamic>[];
    final dayOfCycle = day.difference(DateTime.now()).inDays + cycleData.currentDay;
    
    if (dayOfCycle <= cycleData.periodLength) {
      events.add('Period');
    }
    
    if (dayOfCycle >= cycleData.fertileWindowStartDay && 
        dayOfCycle <= cycleData.fertileWindowEndDay) {
      events.add('Fertile');
    }
    
    if (dayOfCycle == cycleData.ovulationDay) {
      events.add('Ovulation');
    }
    
    return events;
  }

  Widget _buildCalendarLegend(ThemeData theme) {
    final colors = theme.colorScheme;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(colors.primary, 'Period', theme),
        _buildLegendItem(colors.secondary, 'Fertile', theme),
        _buildLegendItem(colors.tertiary, 'Ovulation', theme),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildCyclePhasesSection(CycleData data, ThemeData theme) {
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Cycle Phases",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildPhaseCard(
              title: "Menstruation",
              days: "Day 1-${data.periodLength}",
              icon: Icons.water_drop,
              color: colors.primary,
              isActive: data.currentDay <= data.periodLength,
              theme: theme,
            ),
            _buildPhaseCard(
              title: "Fertile Window",
              days:
                  "Day ${data.fertileWindowStartDay}-${data.fertileWindowEndDay}",
              icon: Icons.favorite,
              color: colors.secondary,
              isActive: data.currentDay >= data.fertileWindowStartDay &&
                  data.currentDay <= data.fertileWindowEndDay,
              theme: theme,
            ),
            _buildPhaseCard(
              title: "Ovulation",
              days: "Day ${data.ovulationDay}",
              icon: Icons.egg,
              color: colors.tertiary,
              isActive: data.currentDay == data.ovulationDay,
              theme: theme,
            ),
            _buildPhaseCard(
              title: "Luteal Phase",
              days: "Day ${data.ovulationDay + 1}-${data.cycleLength}",
              icon: Icons.mood,
              color: colors.primaryContainer,
              isActive: data.currentDay > data.fertileWindowEndDay,
              theme: theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhaseCard({
    required String title,
    required String days,
    required IconData icon,
    required Color color,
    required bool isActive,
    required ThemeData theme,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive
              ? color.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      color: isActive
          ? color.withOpacity(0.1)
          : theme.colorScheme.surfaceVariant.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(isActive ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 20, color: color.withOpacity(isActive ? 1 : 0.7)),
            ),
            const Spacer(),
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isActive
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              days,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isActive
                    ? theme.colorScheme.onSurface.withOpacity(0.8)
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFertilityDetailsSection(CycleData data, ThemeData theme) {
    final colors = theme.colorScheme;
    final isFertile = data.currentDay >= data.fertileWindowStartDay &&
        data.currentDay <= data.fertileWindowEndDay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Fertility Details",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: colors.surfaceVariant,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFertilityDetailItem(
                  label: "Fertile Window",
                  value:
                      "Days ${data.fertileWindowStartDay}-${data.fertileWindowEndDay}",
                  highlight: isFertile,
                  theme: theme,
                ),
                const Divider(height: 20),
                _buildFertilityDetailItem(
                  label: "Ovulation Day",
                  value: "Day ${data.ovulationDay}",
                  highlight: data.currentDay == data.ovulationDay,
                  theme: theme,
                ),
                const Divider(height: 20),
                _buildFertilityDetailItem(
                  label: "Today's Conception Chance",
                  value:
                      "${_getConceptionProbability(data.currentDay, data.ovulationDay)}%",
                  highlight: isFertile,
                  theme: theme,
                ),
                if (isFertile) ...[
                  const Divider(height: 20),
                  _buildFertilityDetailItem(
                    label: "Best Days for Conception",
                    value: "Days ${data.ovulationDay - 2}-${data.ovulationDay}",
                    highlight: true,
                    theme: theme,
                  ),
                ],
                const Divider(height: 20),
                _buildFertilityDetailItem(
                  label: "Next Fertile Window Starts",
                  value: _calculateNextFertileWindowStart(data),
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFertilityDetailItem({
    required String label,
    required String value,
    bool highlight = false,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: highlight
                ? theme.colorScheme.secondary
                : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthSummarySection(
      ProfileProvider profileProvider, ThemeData theme) {
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Health Summary",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: colors.surfaceVariant,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHealthItem(
                  icon: Icons.cake,
                  label: "Age",
                  value:
                      profileProvider.profile!['age']?.toString() ?? 'Not set',
                  theme: theme,
                ),
                const Divider(height: 20),
                _buildHealthItem(
                  icon: Icons.fitness_center,
                  label: "Weight",
                  value: profileProvider.profile!['weight'] != null
                      ? '${profileProvider.profile!['weight']} kg'
                      : 'Not set',
                  theme: theme,
                ),
                const Divider(height: 20),
                _buildHealthItem(
                  icon: Icons.height,
                  label: "Height",
                  value: profileProvider.profile!['height'] != null
                      ? '${profileProvider.profile!['height']} cm'
                      : 'Not set',
                  theme: theme,
                ),
                const Divider(height: 20),
                _buildHealthItem(
                  icon: Icons.repeat,
                  label: "Cycle Length",
                  value: profileProvider.profile!['cycle_length'] != null
                      ? '${profileProvider.profile!['cycle_length']} days'
                      : 'Not set',
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon,
            size: 20, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _calculateNextFertileWindowStart(CycleData data) {
    final nextCycleStart = DateTime.now()
        .add(Duration(days: data.cycleLength - data.currentDay + 1));
    final nextFertileStart =
        nextCycleStart.add(Duration(days: data.fertileWindowStartDay - 1));
    return DateFormat('MMM dd').format(nextFertileStart);
  }

  CycleData _calculateCycleData(ProfileProvider profileProvider, DateTime now) {
    final lastPeriodDate = profileProvider.profile?['last_period_date'] != null
        ? DateTime.parse(profileProvider.profile!['last_period_date'])
        : now.subtract(const Duration(days: 14));
    final cycleLength = profileProvider.profile?['cycle_length'] ?? 28;
    final periodLength = profileProvider.profile?['bleeding_duration'] ?? 5;

    final currentDay = now.difference(lastPeriodDate).inDays + 1;
    final ovulationDay = (cycleLength - 14).clamp(1, cycleLength);
    final fertileWindowStartDay = (ovulationDay - 5).clamp(1, cycleLength);
    final fertileWindowEndDay = (ovulationDay + 1).clamp(1, cycleLength);

    String phase;
    if (currentDay <= periodLength) {
      phase = "Menstruation";
    } else if (currentDay >= fertileWindowStartDay &&
        currentDay <= fertileWindowEndDay) {
      phase = currentDay == ovulationDay ? "Ovulation" : "Fertile Window";
    } else if (currentDay > ovulationDay) {
      phase = "Luteal Phase";
    } else {
      phase = "Follicular Phase";
    }

    return CycleData(
      currentDay: currentDay,
      phase: phase,
      cycleLength: cycleLength,
      periodLength: periodLength,
      ovulationDay: ovulationDay,
      fertileWindowStartDay: fertileWindowStartDay,
      fertileWindowEndDay: fertileWindowEndDay,
      nextPeriodDate: DateFormat('MMM dd').format(
        lastPeriodDate.add(Duration(days: cycleLength)),
      ),
      lastPeriodDate: DateFormat('MMM dd').format(lastPeriodDate),
    );
  }

  double _getConceptionProbability(int currentDay, int ovulationDay) {
    final dayRelativeToOvulation = currentDay - ovulationDay;
    switch (dayRelativeToOvulation) {
      case -5:
        return 10.0;
      case -4:
        return 15.0;
      case -3:
        return 20.0;
      case -2:
        return 27.5;
      case -1:
        return 32.5;
      case 0:
        return 32.5;
      case 1:
        return 12.5;
      default:
        return 0.0;
    }
  }

  Color _getPhaseColor(String phase, ColorScheme colors) {
    switch (phase) {
      case "Menstruation":
        return colors.primary;
      case "Fertile Window":
        return colors.secondary;
      case "Ovulation":
        return colors.tertiary;
      case "Luteal Phase":
        return colors.primaryContainer;
      case "Follicular Phase":
        return colors.primary.withOpacity(0.7);
      default:
        return colors.primary;
    }
  }
}

class CycleData {
  final int currentDay;
  final String phase;
  final int cycleLength;
  final int periodLength;
  final int ovulationDay;
  final int fertileWindowStartDay;
  final int fertileWindowEndDay;
  final String nextPeriodDate;
  final String? lastPeriodDate;

  CycleData({
    required this.currentDay,
    required this.phase,
    required this.cycleLength,
    required this.periodLength,
    required this.ovulationDay,
    required this.fertileWindowStartDay,
    required this.fertileWindowEndDay,
    required this.nextPeriodDate,
    this.lastPeriodDate,
  });
}