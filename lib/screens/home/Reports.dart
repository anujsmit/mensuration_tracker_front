import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mensurationhealthapp/providers/auth_provider.dart';
import 'package:mensurationhealthapp/providers/profile_provider.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  Map<String, dynamic>? _summaryData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    final authProvider = context.read<AuthProvider>();
    // Assume your ProfileProvider or a dedicated ReportsProvider has a method 
    // to call the GET /api/auth/reports/summary route from report.js
    final profileProvider = context.read<ProfileProvider>();
    
    try {
      // You would need to implement this specific API call in your provider
      // For now, we simulate the data structure returned by report.js/summary
      final result = await profileProvider.getSummaryReport(authProvider.token!);
      setState(() {
        _summaryData = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_summaryData == null) {
      return _buildNullState();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Health Reports'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatGrid(),
            const SizedBox(height: 20),
            _buildSymptomBreakdown(),
            const SizedBox(height: 20),
            _buildMoodAnalysis(),
            const SizedBox(height: 30),
            _buildDownloadSection(),
          ],
        ),
      ),
    );
  }

  // Statistics Grid based on report.js summary calculations
  Widget _buildStatGrid() {
    return FadeInDown(
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.5,
        children: [
          _buildStatCard('Avg Cycle', '${_summaryData!['averageCycleLength'] ?? 'N/A'} days', Icons.loop),
          _buildStatCard('Avg Pads/Day', '${_summaryData!['averagePadsPerDay'] ?? 0}', Icons.opacity),
          _buildStatCard('Total Cycles', '${_summaryData!['totalCycles'] ?? 0}', Icons.history),
          _buildStatCard('Period Days', '${_summaryData!['periodDays'] ?? 0}', Icons.calendar_month),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  // Logic from report.js: summary.symptomBreakdown
  Widget _buildSymptomBreakdown() {
    final symptoms = _summaryData!['symptomBreakdown'] as Map<String, dynamic>?;

    return _buildSectionCard(
      'Symptom Breakdown',
      symptoms == null || symptoms.isEmpty
          ? const Center(child: Text('No symptoms recorded yet'))
          : Column(
              children: symptoms.entries.map((e) => ListTile(
                leading: const Icon(Icons.warning_amber),
                title: Text(e.key),
                trailing: Text('${e.value} times', style: const TextStyle(fontWeight: FontWeight.bold)),
              )).toList(),
            ),
    );
  }

  // Logic from report.js: summary.moodBreakdown
  Widget _buildMoodAnalysis() {
    final moods = _summaryData!['moodBreakdown'] as Map<String, dynamic>?;

    return _buildSectionCard(
      'Mood Analysis',
      moods == null || moods.isEmpty
          ? const Center(child: Text('No mood data available'))
          : Column(
              children: moods.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(e.key)),
                    Expanded(
                      flex: 5,
                      child: LinearProgressIndicator(
                        value: (e.value as int) / (_summaryData!['totalNotes'] ?? 1),
                        backgroundColor: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${e.value}'),
                  ],
                ),
              )).toList(),
            ),
    );
  }

  Widget _buildDownloadSection() {
    return FadeInUp(
      child: ElevatedButton.icon(
        onPressed: () {
          // Reuses the logic from profile.dart
          // _downloadReport(); 
        },
        icon: const Icon(Icons.file_download),
        label: const Text('Export Detailed CSV Health Report'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget content) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            const SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildNullState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No Data Available', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const Text('Start logging your cycles to generate reports.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}