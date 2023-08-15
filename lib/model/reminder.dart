import 'package:isar/isar.dart';

part 'reminder.g.dart';

@collection
class Reminder {
  Id id;
  String note;
  DateTime date;
  int categoryID;
  bool isPinned;

  Reminder(this.note, this.date, this.categoryID, this.isPinned, [this.id = Isar.autoIncrement]);
  
  Reminder.fromJson(json) :
    id = json['id'],
    note = json['note'],
    date = json['date'],
    categoryID = json['categoryName'],
    isPinned = json['isPinned'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'note': note,
    'date': date,
    'categoryName': categoryID,
    'isPinned': isPinned
  };
}
