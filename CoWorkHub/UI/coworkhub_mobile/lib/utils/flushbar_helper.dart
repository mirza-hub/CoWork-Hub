import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

void showTopFlushBar({
  required BuildContext context,
  required String message,
  required Color backgroundColor,
}) {
  Flushbar(
    message: message,
    backgroundColor: backgroundColor,
    duration: const Duration(seconds: 3),
    flushbarPosition: FlushbarPosition.TOP,
    margin: const EdgeInsets.all(10),
    borderRadius: BorderRadius.circular(8),
  ).show(context);
}
