part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

class Initialize extends HomeEvent {}
class ReloadData extends HomeEvent {}

class GetAllCategory extends HomeEvent {}

class GetAllReminder extends HomeEvent {}
class CreateReminder extends HomeEvent {
  final Reminder reminder;
  CreateReminder(this.reminder);
}

class UpdateReminder extends HomeEvent {
  final Reminder reminder;
  UpdateReminder(this.reminder);
}

class DeleteReminder extends HomeEvent {
  final Reminder reminder;
  DeleteReminder(this.reminder);
}
