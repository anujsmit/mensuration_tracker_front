import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/cycle_model.dart';

class CycleCard extends StatelessWidget {
  // ======================================================
  // VARIABLES
  // ======================================================

  final CycleModel cycle;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  // ======================================================
  // CONSTRUCTOR
  // ======================================================

  const CycleCard({
    super.key,
    required this.cycle,
    this.onDelete,
    this.onTap,
  });

  // ======================================================
  // FORMAT DATE
  // ======================================================

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final periodDays = cycle.endDate != null
        ? cycle.endDate!.difference(cycle.startDate).inDays + 1
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
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
                // ==============================
                // ICON
                // ==============================

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

                // ==============================
                // DATES
                // ==============================

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(cycle.startDate),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cycle.endDate != null
                            ? 'Ended on ${_formatDate(cycle.endDate!)}'
                            : 'Cycle ongoing',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // ==============================
                // MENU
                // ==============================

                if (onDelete != null)
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: onDelete,
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