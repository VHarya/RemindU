import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;
  String name;

  Category(this.name, [this.id = Isar.autoIncrement]);

  Category.fromJson(json) : name = json['name'];
}
