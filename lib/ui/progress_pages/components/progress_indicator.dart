import 'dart:math' show min;

import 'package:flutter/material.dart';

class ProgressIndicator extends StatefulWidget {
  final double value;
  final Map<int, double> values;

  ProgressIndicator({this.value = 0.0, this.values})
      : assert(value == null || value >= 0.0 && value <= 1.0);

  @override
  _ProgressIndicatorState createState() => _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicator>
    with SingleTickerProviderStateMixin {
  final singleColor = Colors.grey;
  Map<int, double> values;

  @override
  void initState() {
    values = widget.values;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (values != null) {
      final children = <Widget>[];

      for (var studiedTimes in values.keys.toList()
        ..sort((a, b) => a.compareTo(b))) {
        final color = Colors.blueGrey[min(800, 100 + 100 * studiedTimes)];
        children.add(LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            value: widget.value * values[studiedTimes]));
      }

      return Container(
        width: MediaQuery.of(context).size.width,
        height: 4,
        color: Colors.white,
        child: Stack(children: children),
      );
    }

    return LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(singleColor),
        value: widget.value);
  }
}
