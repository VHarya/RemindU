part of 'settings_bloc.dart';

@immutable
sealed class SettingsState {}

final class SettingsInitial extends SettingsState {}

final class Loading extends SettingsState {}
final class OperationFailed extends SettingsState {
  final String reason;
  OperationFailed(this.reason);
}
final class OperationSuccessful extends SettingsState {}

final class GetAllCategoriesSuccessful extends SettingsState {
  final List<Category> categories;
  GetAllCategoriesSuccessful(this.categories);
}
