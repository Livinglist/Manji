import 'package:flutter/material.dart' hide ProgressIndicator;

import 'progress_indicator.dart';

class ProgressListTile extends StatelessWidget {
  final String title;
  final double progress;
  final VoidCallback onTap;
  final Map<int, double> studiedTimes;

  ProgressListTile({this.title, this.progress, this.onTap, this.studiedTimes});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.white)),
      subtitle: ProgressIndicator(value: progress, values: studiedTimes),
      onTap: onTap,
    );
  }
}
