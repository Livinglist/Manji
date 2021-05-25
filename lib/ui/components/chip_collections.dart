import 'package:flutter/material.dart';

class GradeChip extends StatelessWidget {
  final int grade;
  final Color color;
  final String label;
  final TextStyle textStyle;

  GradeChip(
      {@required this.grade,
      this.color = Colors.white,
      this.textStyle =
          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)})
      : label = getStr(grade);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              label,
              style: textStyle,
            )),
        decoration: BoxDecoration(
          //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
          color: color,
          borderRadius: const BorderRadius.all(
              Radius.circular(5.0) //                 <--- border radius here
              ),
        ),
      ),
    );
  }

  static String getStr(int grade) {
    if (grade > 3) {
      return '${grade}th Grade';
    } else {
      switch (grade) {
        case 1:
          return '1st Grade';
        case 2:
          return '2nd Grade';
        case 3:
          return '3rd Grade';
        case 0:
          return 'Junior High';
        default:
          throw Exception('Unmatched grade');
      }
    }
  }
}

class StrokeChip extends StatelessWidget {
  final Color color;
  final int stokeCount;
  final String label;
  final bool isCompact;

  StrokeChip({this.color = Colors.white, this.stokeCount})
      : isCompact = false,
        label = "${"$stokeCount stroke"}${stokeCount == 1 ? "" : "s"}";

  StrokeChip.compact({this.color = Colors.white, this.stokeCount})
      : isCompact = true,
        label = "${"$stokeCount stroke"}${stokeCount == 1 ? "" : "s"}";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              label,
              style: TextStyle(
                  fontSize: isCompact ? 12 : 18, fontWeight: FontWeight.bold),
            )),
        decoration: BoxDecoration(
          //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
          color: color,
          borderRadius: const BorderRadius.all(
              Radius.circular(5.0) //                 <--- border radius here
              ),
        ),
      ),
    );
  }
}

class JLPTChip extends StatelessWidget {
  final Color color;
  final int jlpt;
  final String label;
  final bool isCompact;

  JLPTChip({this.color = Colors.white, this.jlpt})
      : isCompact = false,
        label = "N$jlpt";

  JLPTChip.compact({this.color = Colors.white, this.jlpt})
      : isCompact = true,
        label = "N$jlpt";

  @override
  Widget build(BuildContext context) {
    if (jlpt == 0) return Container();
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              label,
              style: TextStyle(
                  fontSize: isCompact ? 12 : 18, fontWeight: FontWeight.bold),
            )),
        decoration: BoxDecoration(
          //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
          color: color,
          borderRadius: const BorderRadius.all(
              Radius.circular(5.0) //                 <--- border radius here
              ),
        ),
      ),
    );
  }
}
