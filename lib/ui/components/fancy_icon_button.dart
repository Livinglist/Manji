import 'dart:math';

import 'package:flutter/material.dart';

enum IconType {star, fav}

class FancyIconButton extends StatefulWidget {
  final bool isFaved;
  final VoidCallback onTapped;
  final IconType iconType;

  FancyIconButton({@required this.isFaved, this.onTapped, this.iconType = IconType.star});

  @override
  State<StatefulWidget> createState() => FancyIconButtonState();
}

class FancyIconButtonState extends State<FancyIconButton> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Tween<double> tween = Tween(begin: 0.0, end: 6 * pi);
  Icon icon;
  bool isFaved;
  ColorTween colorTween;

  @override
  void initState() {
    isFaved = widget.isFaved;

    if(widget.iconType == IconType.star) {
      icon = isFaved ? Icon(Icons.star) : Icon(Icons.star_border);
      colorTween = isFaved? ColorTween(begin: Colors.yellow, end: Colors.white):ColorTween(begin: Colors.white, end: Colors.yellow);
    }
    else {
      icon = isFaved ? Icon(Icons.favorite) : Icon(Icons.favorite_border);
      colorTween = isFaved? ColorTween(begin: Colors.red, end: Colors.white):ColorTween(begin: Colors.white, end: Colors.red);
    }
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 200))
      ..addListener(() {
        if (animationController.isAnimating) {
          setState(() {
            if(widget.iconType == IconType.star) {
              icon = isFaved ? Icon(Icons.star) : Icon(Icons.star_border);
            }
            else {
              icon = isFaved ? Icon(Icons.favorite) : Icon(Icons.favorite_border);
            }
          });
        }
      });
    //animationController.forward();
    super.initState();
  }

  void changeStatus() {
    isFaved = !isFaved;
    if (animationController.status == AnimationStatus.completed)
      animationController.reverse();
    else
      animationController.forward();
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
