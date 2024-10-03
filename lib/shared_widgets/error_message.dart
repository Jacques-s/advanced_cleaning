import 'package:flutter/material.dart';

class ErrorMessageText extends StatelessWidget {
  const ErrorMessageText({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message != null) {
      return Text(
        message!,
        style: const TextStyle(fontSize: 12, color: Colors.red),
      );
    } else {
      return const SizedBox();
    }
  }
}
