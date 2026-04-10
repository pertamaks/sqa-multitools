import 'package:flutter/material.dart';

class VulnerabilityCategory {
  final String name;
  final String description;
  final IconData icon;
  final List<SecurityPayload> payloads;

  const VulnerabilityCategory({
    required this.name,
    required this.description,
    required this.icon,
    required this.payloads,
  });
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
    this.risk = PayloadRisk.medium,
  });
}

enum PayloadRisk {
  low,
  medium,
  high,
  critical,
}
