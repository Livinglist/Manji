import 'package:flutter/material.dart' hide ProgressIndicator;

import 'progress_indicator.dart';

class ProgressListTile extends StatelessWidget {
  final String title;
  final double progress;
  final VoidCallback onTap;
  final Map<int, double> studiedTimes;
  final double totalStudiedPercentage;

  ProgressListTile(
      {this.title,
      this.progress,
      this.onTap,
      this.studiedTimes,
      this.totalStudiedPercentage});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      leading: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Container(
            width: 36,
            height: 36,
            child: Center(
              child: Text(
                  '${(totalStudiedPercentage ?? (progress * 100)).truncate()}%',
                  style: const TextStyle(color: Colors.white)),
            ),
          )),
      subtitle: ProgressIndicator(value: progress, values: studiedTimes),
      onTap: onTap,
    );
  }
}
