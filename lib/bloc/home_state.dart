part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class Loading extends HomeState {}

final class ReloadingData extends HomeState {}
final class OperationFailed extends HomeState {
  final String reason;
  OperationFailed(this.reason);
}

final class HomeInitial extends HomeState {}
final class InitializeFinished extends HomeState {
  final Map<String, List<Reminder>> data;
  final List<Category> categories;

  InitializeFinished(this.categories, this.data);
}

final class GetAllCategorySuccessful extends HomeState {
  final List<Category> categories;
  GetAllCategorySuccessful(this.categories);
}
final class GetAllReminderSuccessful extends HomeState {
  final Map<String, List<Reminder>> data;
  GetAllReminderSuccessful(this.data);
}

final class CreateReminderSuccessful extends HomeState {
  final Reminder reminder;
  CreateReminderSuccessful(this.reminder);
}
final class UpdateReminderSuccessful extends HomeState {}
final class DeleteReminderSuccessful extends HomeState {}
final class PinReminderSuccessful extends HomeState {}

