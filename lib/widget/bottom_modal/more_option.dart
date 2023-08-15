import 'package:flutter/material.dart';

class MoreOptions extends StatefulWidget {
  final bool isPinned;
  final Function() onPinPressed;
  final Function() onEditPressed;
  final Function() onDeletePressed;
  const MoreOptions({
    super.key,
    required this.isPinned,
    required this.onPinPressed,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  State<MoreOptions> createState() => _MoreOptionsState();
}

class _MoreOptionsState extends State<MoreOptions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: widget.onPinPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.push_pin_outlined,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.isPinned ? "Unpin Reminder" : "Pin Reminder",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: widget.onEditPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 10),
                Text(
                  "Edit Reminder",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: widget.onDeletePressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 10),
                Text(
                  "Delete Reminder",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}