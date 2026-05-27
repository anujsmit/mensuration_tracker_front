// lib/models/pads_tracking.dart
import 'package:flutter/material.dart';

class PadsTracking {
  final String? id;
  final DateTime date;
  final int padsUsed;
  final int tamponsUsed;
  final int linersUsed;
  final String? flowIntensity;

  PadsTracking({
    this.id,
    required this.date,
    this.padsUsed = 0,
    this.tamponsUsed = 0,
    this.linersUsed = 0,
    this.flowIntensity,
  });

  factory PadsTracking.fromJson(Map<String, dynamic> json) {
    return PadsTracking(
      id: json['id']?.toString(),
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      padsUsed: (json['pads_used'] as num?)?.toInt() ?? 0,
      tamponsUsed: (json['tampons_used'] as num?)?.toInt() ?? 0,
      linersUsed: (json['liners_used'] as num?)?.toInt() ?? 0,
      flowIntensity: json['flow_intensity']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'date': date.toIso8601String().split('T')[0],
      'pads_used': padsUsed,
      'tampons_used': tamponsUsed,
      'liners_used': linersUsed,
      if (flowIntensity != null) 'flow_intensity': flowIntensity,
    };
  }

  // Helper method to get total products used
  int get totalProducts => padsUsed + tamponsUsed + linersUsed;

  // Helper method to get flow intensity display name
  String get flowIntensityDisplay {
    switch (flowIntensity) {
      case 'light':
        return 'Light';
      case 'medium':
        return 'Medium';
      case 'heavy':
        return 'Heavy';
      case 'very_heavy':
        return 'Very Heavy';
      default:
        return 'Not specified';
    }
  }

  // Helper method to get flow intensity icon
  IconData get flowIntensityIcon {
    switch (flowIntensity) {
      case 'light':
        return Icons.water_drop_outlined;
      case 'medium':
        return Icons.water_drop;
      case 'heavy':
        return Icons.water_drop_sharp;
      case 'very_heavy':
        return Icons.water;
      default:
        return Icons.water_drop;
    }
  }

  // Helper method to get flow intensity color
  Color get flowIntensityColor {
    switch (flowIntensity) {
      case 'light':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'heavy':
        return Colors.red;
      case 'very_heavy':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Create a copy with updated values
  PadsTracking copyWith({
    String? id,
    DateTime? date,
    int? padsUsed,
    int? tamponsUsed,
    int? linersUsed,
    String? flowIntensity,
  }) {
    return PadsTracking(
      id: id ?? this.id,
      date: date ?? this.date,
      padsUsed: padsUsed ?? this.padsUsed,
      tamponsUsed: tamponsUsed ?? this.tamponsUsed,
      linersUsed: linersUsed ?? this.linersUsed,
      flowIntensity: flowIntensity ?? this.flowIntensity,
    );
  }

  @override
  String toString() {
    return 'PadsTracking(id: $id, date: ${date.toIso8601String().split('T')[0]}, padsUsed: $padsUsed, tamponsUsed: $tamponsUsed, linersUsed: $linersUsed, flowIntensity: $flowIntensity)';
  }
}

class PadsStatistics {
  final int totalPads;
  final int totalTampons;
  final int totalLiners;
  final double averagePerDay;
  final int daysTracked;
  final Map<String, int> flowIntensityCount;

  PadsStatistics({
    required this.totalPads,
    required this.totalTampons,
    required this.totalLiners,
    required this.averagePerDay,
    required this.daysTracked,
    required this.flowIntensityCount,
  });

  factory PadsStatistics.fromJson(Map<String, dynamic> json) {
    return PadsStatistics(
      totalPads: (json['total_pads'] as num?)?.toInt() ?? 0,
      totalTampons: (json['total_tampons'] as num?)?.toInt() ?? 0,
      totalLiners: (json['total_liners'] as num?)?.toInt() ?? 0,
      averagePerDay: (json['average_per_day'] as num?)?.toDouble() ?? 0.0,
      daysTracked: (json['days_tracked'] as num?)?.toInt() ?? 0,
      flowIntensityCount: Map<String, int>.from(json['flow_intensity_count'] ?? {}),
    );
  }

  // Get total products used
  int get totalProducts => totalPads + totalTampons + totalLiners;

  // Get most used product type
  String get mostUsedProduct {
    if (totalPads >= totalTampons && totalPads >= totalLiners) return 'Pads';
    if (totalTampons >= totalPads && totalTampons >= totalLiners) return 'Tampons';
    return 'Liners';
  }

  // Get most common flow intensity
  String get mostCommonFlowIntensity {
    if (flowIntensityCount.isEmpty) return 'No data';
    return flowIntensityCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  // Get days with heavy flow
  int get heavyFlowDays {
    return (flowIntensityCount['heavy'] ?? 0) + (flowIntensityCount['very_heavy'] ?? 0);
  }

  // Get percentage of days with heavy flow
  double get heavyFlowPercentage {
    if (daysTracked == 0) return 0;
    return (heavyFlowDays / daysTracked) * 100;
  }

  @override
  String toString() {
    return 'PadsStatistics(totalPads: $totalPads, totalTampons: $totalTampons, totalLiners: $totalLiners, averagePerDay: $averagePerDay, daysTracked: $daysTracked)';
  }
}

// Helper class for daily tracking summary
class DailyTrackingSummary {
  final DateTime date;
  final int totalProducts;
  final String? flowIntensity;
  final bool hasData;

  DailyTrackingSummary({
    required this.date,
    required this.totalProducts,
    this.flowIntensity,
    this.hasData = false,
  });

  factory DailyTrackingSummary.fromPadsTracking(PadsTracking tracking) {
    return DailyTrackingSummary(
      date: tracking.date,
      totalProducts: tracking.totalProducts,
      flowIntensity: tracking.flowIntensity,
      hasData: true,
    );
  }

  factory DailyTrackingSummary.empty(DateTime date) {
    return DailyTrackingSummary(
      date: date,
      totalProducts: 0,
      hasData: false,
    );
  }
}