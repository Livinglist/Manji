import 'dart:math';

import 'package:flutter/material.dart';

enum IconType { star, fav }

class FancyIconButton extends StatefulWidget {
  final bool isFaved;
  final VoidCallback onTapped;
  final IconData icon;
  final IconData iconBorder;
  final Color color;

  FancyIconButton(
      {@required this.isFaved,
      this.onTapped,
      this.icon,
      this.iconBorder,
      this.color});

  @override
  State<StatefulWidget> createState() => FancyIconButtonState();
}

class FancyIconButtonState extends State<FancyIconButton>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Tween<double> tween = Tween(begin: 0.0, end: 6 * pi);
  Icon icon;
  bool isFaved;
  ColorTween colorTween;

  @override
  void initState() {
    isFaved = widget.isFaved;

    icon = isFaved ? Icon(widget.icon) : Icon(widget.iconBorder);
    colorTween = isFaved
        ? ColorTween(begin: widget.color, end: Colors.white)
        : ColorTween(begin: Colors.white, end: widget.color);

    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(() {
        if (animationController.isAnimating) {
          setState(() {
            icon = isFaved ? Icon(widget.icon) : Icon(widget.iconBorder);
          });
        }
      });
    //animationController.forward();
    super.initState();
  }

  void changeStatus() {
    isFaved = !isFaved;
    if (animationController.status == AnimationStatus.completed) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (_, __) {
        return Transform.rotate(
            angle: tween.animate(animationController).value,
            child: IconButton(
              icon: icon,
              color: colorTween.animate(animationController).value,
              onPressed: () {
                changeStatus();
                widget.onTapped();
              },
            ));
      },
    );
  }
}
