import 'package:flutter/material.dart';

class LabelDivider extends StatelessWidget {
  final Widget child;

  LabelDivider({@required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(12),
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            const Flexible(
              flex: 4,
              child: Divider(color: Colors.white60),
            ),
            Flexible(
                flex: 3,
                child: Container(
                  child: Center(child: child),
                )),
            const Flexible(
              flex: 4,
              child: Divider(color: Colors.white60),
            ),
          ],
        ));
  }
}
