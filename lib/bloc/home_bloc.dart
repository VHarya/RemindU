import 'package:meta/meta.dart';

import 'package:bloc/bloc.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:remind_u/model/category.dart';
import 'package:remind_u/model/reminder.dart';

part 'home_event.dart';
part 'home_state.dart';

Isar? isar;

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<ReloadData>((event, emit) => emit(ReloadingData()));
    on<Initialize>(initialize);
    on<GetAllReminder>(getAllReminder);
    on<CreateReminder>(createReminder);
    on<UpdateReminder>(updateReminder);
    on<DeleteReminder>(deleteReminder);
  }
}

Future openIsar() async {
  isar = Isar.getInstance();
  if (isar != null) return;

  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [ReminderSchema, CategorySchema],
    directory: dir.path,
  );
}

Future initialize(Initialize event, Emitter<HomeState> emit) async {
  emit(Loading());

  await openIsar();
  
  DateTime now = DateTime.now();
  now = DateTime(now.year, now.month, now.day, 23, 00);
  
  List<Category> categories = [];
  List<Reminder> pinnedReminder = [];
  List<Reminder> normalReminder = [];

  try {
    categories = await isar!.categorys
      .where()
      .findAll();
  } catch (e) {
    emit(OperationFailed("(categories) Failed to fetch data."));
    return;
  }
  
  try {
    pinnedReminder = await isar!.reminders
      .where(sort: Sort.asc)
      .filter()
      .isPinnedEqualTo(true)
      .and()
      .not().dateLessThan(now)
      .sortByDateDesc()
      .findAll();
  } catch (e) {
    emit(OperationFailed("(pinned-reminder) Failed to fetch data."));
    return;
  }
  
  try {
    normalReminder = await isar!.reminders
      .where(sort: Sort.asc)
      .filter()
      .isPinnedEqualTo(false)
      .or()
      .dateLessThan(now)
      .sortByDateDesc()
      .findAll();
  } catch (e) {
    emit(OperationFailed("(normal-reminder) Failed to fetch data."));
    return;
  }
  
  final data = {
    "pinned": pinnedReminder,
    "normal": normalReminder,
  };

  emit(InitializeFinished(categories, data));
}
// ---- INITIALIZE ---- //



// ---- CATEGORY ---- //
Future getAllCategory(GetAllCategory event, Emitter<HomeState> emit) async {
  emit(Loading());

  List<Category> categories = [];

  try {
    categories = await isar!.categorys
      .where()
      .findAll();
  } catch (e) {
    emit(OperationFailed("(categories) Failed to fetch data."));
    return;
  }

  emit(GetAllCategorySuccessful(categories));
}
// ---- CATEGORY ---- //



// ---- REMINDER ---- //
Future getAllReminder(GetAllReminder event, Emitter<HomeState> emit) async {
  emit(Loading());

  DateTime now = DateTime.now();
  now = DateTime(now.year, now.month, now.day, 23, 00);

  List<Reminder> pinnedReminder = [];
  List<Reminder> normalReminder = [];

  try {
    pinnedReminder = await isar!.reminders
      .where(sort: Sort.asc)
      .filter()
      .isPinnedEqualTo(true)
      .and()
      .not().dateLessThan(now)
      .sortByDateDesc()
      .findAll();
  } catch (e) {
    emit(OperationFailed("(pinned-reminder) Failed to fetch data."));
    return;
  }
  
  try {
    normalReminder = await isar!.reminders
      .where(sort: Sort.asc)
      .filter()
      .isPinnedEqualTo(false)
      .or()
      .dateLessThan(now)
      .sortByDateDesc()
      .findAll();
  } catch (e) {
    emit(OperationFailed("(normal-reminder) Failed to fetch data."));
    return;
  }
  
  final data = {
    "pinned": pinnedReminder,
    "normal": normalReminder,
  };

  emit(GetAllReminderSuccessful(data));
}

Future createReminder(CreateReminder event, Emitter<HomeState> emit) async {
  emit(Loading());

  final reminder = event.reminder;

  try {
    await isar!.writeTxn(() async {
      await isar!.reminders.put(reminder);
    });
  } catch (e) {
    emit(OperationFailed("(create-reminder) Failed to create data."));
    return;
  }
  
  emit(CreateReminderSuccessful(reminder));
}

Future updateReminder(UpdateReminder event, Emitter<HomeState> emit) async {
  emit(Loading());
  final reminder = event.reminder;

  try {
    await isar!.writeTxn(() async {
      await isar!.reminders.put(reminder);
    });
  } catch (e) {
    emit(OperationFailed("(pin-reminder) Failed to update data."));
    return;
  }
  
  emit(ReloadingData());
}

Future deleteReminder(DeleteReminder event, Emitter<HomeState> emit) async {
  emit(Loading());
  
  try {
    await isar!.writeTxn(() async {
      await isar!.reminders.delete(event.reminder.id);
    });
  } catch (e) {
    emit(OperationFailed("(delete-reminder) Failed to delete data."));
    return;
  }
  
  emit(ReloadingData());
}
// ---- REMINDER ---- //
