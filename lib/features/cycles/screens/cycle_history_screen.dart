import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/cycle_provider.dart';
import '../models/cycle_model.dart';

class CycleHistoryScreen extends StatefulWidget {
  const CycleHistoryScreen({super.key});

  @override
  State<CycleHistoryScreen> createState() => _CycleHistoryScreenState();
}

class _CycleHistoryScreenState extends State<CycleHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _fetchCycles();
  }

  Future<void> _fetchCycles() async {
    await Provider.of<CycleProvider>(context, listen: false).fetchCycles();
  }

  // ======================================================
  // FORMAT DATE
  // ======================================================

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // ======================================================
  // DELETE
  // ======================================================

  Future<void> _deleteCycle(String id) async {
    final provider = Provider.of<CycleProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Cycle'),
          content: const Text('Are you sure you want to delete this cycle?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final success = await provider.deleteCycle(id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cycle deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.error ?? "Failed to delete cycle"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CycleProvider>(context);
    final cycles = provider.cycles;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Cycle History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cycles.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchCycles,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(18),
                    itemCount: cycles.length,
                    itemBuilder: (context, index) {
                      final cycle = cycles[index];
                      return _buildCycleCard(cycle);
                    },
                  ),
                ),
    );
  }

  // ======================================================
  // EMPTY STATE
  // ======================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month,
              size: 90,
              color: Colors.pink.shade200,
            ),
            const SizedBox(height: 20),
            const Text(
              'No Cycle History',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your menstrual cycle history will appear here.\nTap the + button to add your first cycle.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // CYCLE CARD
  // ======================================================

  Widget _buildCycleCard(CycleModel cycle) {
    final periodDays = cycle.endDate != null
        ? cycle.endDate!.difference(cycle.startDate).inDays + 1
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================
          // HEADER
          // ==================================

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite,
                  color: Colors.pink.shade400,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDate(cycle.startDate),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cycle.endDate != null
                          ? 'Ended on ${formatDate(cycle.endDate!)}'
                          : 'Cycle ongoing',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () => _deleteCycle(cycle.id),
                    child: const Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ==================================
          // STATS
          // ==================================

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Cycle Length',
                  value: '${cycle.cycleLength ?? '--'} days',
                  icon: Icons.sync,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Period Days',
                  value: periodDays != null ? '$periodDays days' : '--',
                  icon: Icons.water_drop,
                ),
              ),
            ],
          ),

          // ==================================
          // NOTES
          // ==================================

          if (cycle.notes != null && cycle.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  cycle.notes!,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ======================================================
  // STAT CARD
  // ======================================================

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.pink.shade400),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}