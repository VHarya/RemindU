import 'package:flutter/material.dart';

class DeleteDialog extends StatefulWidget {
  final String text;
  final Function() onCancelPressed;
  final Function() onDeletePressed;
  const DeleteDialog({
    super.key,
    required this.text,
    required this.onCancelPressed,
    required this.onDeletePressed,
  });

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.text),
      actions: [
        TextButton(
          child: const Text(
            "Cancel",
            style: TextStyle(
              color: Color(0xFF333333)
            ),
          ),
          onPressed: () => widget.onCancelPressed(),
        ),
        TextButton(
          child: const Text(
            "Delete",
            style: TextStyle(
              color: Color(0xFF333333)
            ),
          ),
          onPressed: () => widget.onDeletePressed(),
        ),
      ],
    );
  }
}