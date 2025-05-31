import 'package:flutter/material.dart';

class ExpenseItem {
  final IconData icon;
  final String name;
  final int percent;
  final double value;

  ExpenseItem({
    required this.icon,
    required this.name,
    required this.percent,
    required this.value,
  });
}

