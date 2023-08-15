import 'package:flutter/material.dart';
import 'package:remind_u/main.dart';
import 'package:remind_u/model/reminder.dart';

class NormalReminder extends StatelessWidget {
  final Reminder reminder;
  final Function() onPressed;
  final Function() onLongPressed;
  
  const NormalReminder({
    super.key,
    required this.reminder,
    required this.onPressed,
    required this.onLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      child: InkWell(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  reminder.note,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  reminder.date.customFormat(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}