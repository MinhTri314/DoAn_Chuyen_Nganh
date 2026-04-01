import 'package:flutter/material.dart';

class Activity {
  final String title;
  final String time;
  final String location;
  final IconData icon;
  final Color color;

  Activity({
    required this.title,
    required this.time,
    required this.location,
    required this.icon,
    required this.color,
  });
}