import 'package:flutter/material.dart';
import 'package:remind_u/main.dart';
import 'package:remind_u/model/reminder.dart';

class PinnedReminder extends StatelessWidget {
  final Reminder reminder;
  final Function() onPressed;
  final Function() onLongPressed;
  
  const PinnedReminder({
    super.key,
    required this.reminder,
    required this.onPressed,
    required this.onLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      onLongPress: onLongPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(color: const Color(0xFFE6E6E6)),
          borderRadius: BorderRadius.circular(5)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              reminder.note,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.push_pin_outlined,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                Text(
                  reminder.date.customFormat(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}