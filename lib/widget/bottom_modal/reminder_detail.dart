import 'package:flutter/material.dart';
import 'package:remind_u/main.dart';
import 'package:remind_u/model/category.dart';
import 'package:remind_u/model/reminder.dart';

class ReminderDetail extends StatefulWidget {
  final Reminder reminder;
  final Category category;
  const ReminderDetail({
    super.key,
    required this.reminder,
    required this.category,
  });

  @override
  State<ReminderDetail> createState() => _ReminderDetailState();
}

class _ReminderDetailState extends State<ReminderDetail> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- HEADER ---- //
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.name,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  Text(
                    widget.reminder.date.customFormat(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w300
                    ),
                  )
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context, true);
                },
                child: const Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(Icons.more_vert),
                ),
              ),
            ],
          ),
          // ---- HEADER ---- //
    
          const SizedBox(height: 10),
          
          // ---- REMINDER ---- //
          Text(
            widget.reminder.note,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          )
          // ---- REMINDER ---- //
        ],
      ),
    );
  }
}