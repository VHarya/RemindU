part of 'settings_bloc.dart';

@immutable
sealed class SettingsEvent {}

final class GetAllCategories extends SettingsEvent {}
final class CreateCategory extends SettingsEvent {
  final Category category;
  CreateCategory(this.category);
}
final class EditCategory extends SettingsEvent {
  final Category category;
  EditCategory(this.category);
}
final class DeleteCategory extends SettingsEvent {
  final Category category;
  DeleteCategory(this.category);
} 
