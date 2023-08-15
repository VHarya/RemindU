import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remind_u/main.dart';
import 'package:remind_u/model/category.dart';
import 'package:remind_u/model/reminder.dart';

class EditReminderDialog extends StatefulWidget {
  final Reminder reminder;
  final List<Category> categories;
  final Function(Reminder reminder) onDonePressed;
  const EditReminderDialog({
    super.key,
    required this.reminder,
    required this.categories,
    required this.onDonePressed,
  });

  @override
  State<EditReminderDialog> createState() => _EditReminderDialogState();
}

class _EditReminderDialogState extends State<EditReminderDialog> {
  final TextEditingController noteController = TextEditingController();
  DateTime dateTime = DateTime.now();
  Category? selectedCategory;
  bool validateNoteEmpty = false;

  @override
  void initState() {
    super.initState();
    print("init edit ${widget.reminder.toJson()}");
    dateTime = widget.reminder.date;
    selectedCategory = widget.categories.firstWhere((element) => element.id == widget.reminder.categoryID);
    noteController.text = widget.reminder.note;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Edit Reminder",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: 10),

          // ---- DATE TIME ---- //
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 2,
                child: DateInputButton(
                  dateTime: dateTime,
                  selectedDate: (date) => setState(() => dateTime = date),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: TimeInputButton(
                  dateTime: dateTime,
                  selectedTime: (date) => setState(() => dateTime = date),
                ),
              ),
            ],
          ),
          // ---- DATE TIME ---- //

          const SizedBox(height: 10),

          // ---- CATEGORY ---- //
          Text(
            "Category",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              border: const Border(bottom: BorderSide(color: Color(0xFF333333)))
            ),
            child: DropdownButton<Category>(
              dropdownColor: Theme.of(context).scaffoldBackgroundColor,
              underline: const SizedBox(),
              isExpanded: true,
              padding: EdgeInsets.zero,
              value: selectedCategory ?? widget.categories[0],
              items: List.generate(
                widget.categories.length,
                (index) => DropdownMenuItem(
                  value: widget.categories[index],
                  child: Text(
                    widget.categories[index].name.capitalize(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() => selectedCategory = value);
              },
            ),
          ),
          // ---- CATEGORY ---- //

          const SizedBox(height: 10),
          
          // ---- NOTE ---- //
          Text(
            "Note",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: noteController,
            maxLines: 3,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(.15),
              hintText: "Enter Note",
              errorText: validateNoteEmpty ? "Note can't be empty!" : null,
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF333333))
              )
            ),
          ),
          // ---- NOTE ---- //

          
          // ---- BUTTONS ---- //
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  if (noteController.text.isEmpty) {
                    setState(() => validateNoteEmpty = true);
                    return;
                  }

                  selectedCategory ??= widget.categories[0];

                  widget.onDonePressed(
                    Reminder(noteController.text, dateTime, selectedCategory!.id, false, widget.reminder.id)
                  );
                },
                child: const Text("Save"),
              ),
            ],
          ),
          // ---- BUTTONS ---- //
        ],
      ),
    );
  }
}



// ---- INPUTS ---- //

class DateInputButton extends StatelessWidget {
  final DateTime dateTime;
  final Function(DateTime date) selectedDate;
  const DateInputButton({
    super.key,
    required this.dateTime,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return GestureDetector(
      onTap: () => showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: dateTime.subtract(const Duration(days: 3650)),
        lastDate: now.add(const Duration(days: 3650)),
        builder: (context, child) => ClipRRect(
          child: child,
        ),
      ).then((value) {
        if (value == null) {
          selectedDate(dateTime);
        } else {
          DateTime selected = DateTime(value.year, value.month, value.day, dateTime.hour, dateTime.minute);
          selectedDate(selected);
        }
      }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Date",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              border: const Border(bottom: BorderSide(color: Color(0xFF333333)),),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              DateFormat("d MMMM y").format(dateTime),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimeInputButton extends StatelessWidget {
  final DateTime dateTime;
  final Function(DateTime date) selectedTime;
  const TimeInputButton({
    super.key,
    required this.dateTime,
    required this.selectedTime,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(dateTime),
      ).then(
        (value) {
          if (value == null) {
            selectedTime(dateTime);
          } else {
            DateTime selected = DateTime(dateTime.year, dateTime.month, dateTime.day, value.hour, value.minute);
            selectedTime(selected);
          }
        }
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Time",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              border: const Border(
                bottom: BorderSide(color: Color(0xFF333333)),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              DateFormat("HH:mm").format(dateTime),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
