import 'package:bloc/bloc.dart';
import 'package:isar/isar.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:remind_u/model/category.dart';

part 'settings_event.dart';
part 'settings_state.dart';

Isar? isar;

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial()) {
    openIsar();

    on<GetAllCategories>(getAllCategories);
    on<CreateCategory>(createCategory);
    on<EditCategory>(editCategory);
    on<DeleteCategory>(deleteCategory);
  }
}

Future openIsar() async {
  isar = Isar.getInstance();
  if (isar != null) return;
  
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [CategorySchema],
    directory: dir.path
  );
}

Future getAllCategories(GetAllCategories event, Emitter<SettingsState> emit) async {
  emit(Loading());
  
  List<Category> categories = [];

  try {
    categories = await isar!.categorys
      .where()
      .findAll();
  } catch (e) {
    emit(OperationFailed("(get-categories) Failed to fetch data"));
  }

  emit(GetAllCategoriesSuccessful(categories));
}

Future createCategory(CreateCategory event, Emitter<SettingsState> emit) async {
  emit(Loading());

  try {
    await isar!.writeTxn(() async {
      await isar!.categorys.put(event.category);
    });
  } catch (e) {
    emit(OperationFailed("(get-categories) Failed to fetch data"));
  }

  emit(OperationSuccessful());
}

Future editCategory(EditCategory event, Emitter<SettingsState> emit) async {
  emit(Loading());

  try {
    await isar!.writeTxn(() async {
      await isar!.categorys.put(event.category);
    });
  } catch (e) {
    emit(OperationFailed("(get-categories) Failed to fetch data"));
  }

  emit(OperationSuccessful());
}

Future deleteCategory(DeleteCategory event, Emitter<SettingsState> emit) async {
  emit(Loading());

  try {
    await isar!.writeTxn(() async {
      await isar!.categorys.delete(event.category.id);
    });
  } catch (e) {
    emit(OperationFailed("(delete-category) Failed to delete data"));
  }

  emit(OperationSuccessful());
}
