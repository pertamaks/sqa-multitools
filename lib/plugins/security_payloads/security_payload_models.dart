import 'package:flutter/material.dart';

enum PayloadRisk {
  low,
  medium,
  high,
  critical,
  info;

  static PayloadRisk fromString(String risk) {
    final lower = risk.toLowerCase();
    if (lower.contains('critical') ||
        lower.contains('💀') ||
        lower.contains('🟣')) {
      return PayloadRisk.critical;
    }
    if (lower.contains('high') || lower.contains('🔴')) return PayloadRisk.high;
    if (lower.contains('medium') ||
        lower.contains('🟠') ||
        lower.contains('🟡')) {
      return PayloadRisk.medium;
    }
    if (lower.contains('low') || lower.contains('🟢')) return PayloadRisk.low;
    return PayloadRisk.info;
  }
}

class SecurityPayload {
  final String name;
  final String payload;
  final String description;
  final String howToTest;
  final String successIndicator;
  final PayloadRisk risk;

  const SecurityPayload({
    required this.name,
    required this.payload,
    required this.description,
    required this.howToTest,
    required this.successIndicator,
    required this.risk,
  });
}

class PayloadCategory {
  final String name;
  final String description;
  final IconData icon;
  final List<PayloadSection> sections;

  const PayloadCategory({
    required this.name,
    required this.description,
    required this.icon,
    required this.sections,
  });
}

class PayloadSection {
  final String id;
  final String title;
  final IconData icon;
  final String markdown;
  final List<SecurityPayload>? structuredPayloads;

  const PayloadSection({
    required this.id,
    required this.title,
    required this.icon,
    required this.markdown,
    this.structuredPayloads,
  });
}
