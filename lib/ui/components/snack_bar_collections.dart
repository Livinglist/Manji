import 'package:flutter/material.dart';

class WarningSnackBar extends SnackBar {
  final String message;

  WarningSnackBar({this.message})
      : super(backgroundColor: Colors.red, content: Text(message));
}
