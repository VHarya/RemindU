import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:remind_u/main.dart';
import 'package:remind_u/bloc/settings_bloc.dart';
import 'package:remind_u/model/category.dart';
import 'package:remind_u/widget/delete_dialog.dart';
import 'package:remind_u/widget/category_list_item.dart';
import 'package:remind_u/widget/form/category_create.dart';
import 'package:remind_u/widget/form/category_edit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Category> categories = [];
  ThemeMode currentTheme = ThemeMode.system;
  bool isLoading = false;

  void showAddForm(BuildContext builderContext) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Wrap(
          children: [
            CategoryCreateForm(
              onDonePressed: (category) {
                BlocProvider.of<SettingsBloc>(builderContext).add(CreateCategory(category));
              },
            ),
          ],
        ),
      ),
    );
  }

  void showEditForm(BuildContext builderContext, Category category) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Wrap(
          children: [
            CategoryEditForm(
              category: category,
              onDonePressed: (category) {
                BlocProvider.of<SettingsBloc>(builderContext).add(EditCategory(category));
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void showDeleteDialog(BuildContext builderContext, Category category) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        text: "Are you sure you want to delete this Category?",
        onCancelPressed: () => Navigator.pop(context),
        onDeletePressed: () {
          BlocProvider.of<SettingsBloc>(builderContext).add(DeleteCategory(category));
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    currentTheme = MyApp.of(context).currentThemeMode();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>(
      create: (context) => SettingsBloc(),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          isLoading = false;

          switch (state.runtimeType) {
            case SettingsInitial:
              BlocProvider.of<SettingsBloc>(context).add(GetAllCategories());
            case Loading:
              isLoading = true;
              break;
            case OperationSuccessful:
              BlocProvider.of<SettingsBloc>(context).add(GetAllCategories());
              Navigator.pop(context);
              break;
            case OperationFailed:
              final st = state as OperationFailed;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(st.reason))
              );
              Navigator.pop(context);
              break;
            case GetAllCategoriesSuccessful:
              final st = state as GetAllCategoriesSuccessful;
              categories = st.categories;
              break;
            default:
          }


          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      // ---- HEADER ---- //
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            child: Padding(
                              padding: const EdgeInsets.all(1),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            onTap: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Settings",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      // ---- HEADER ---- //
            
                      const SizedBox(height: 20),
            
                      // ---- CONTENT ---- //
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ---- CATEGORIES ---- //
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Categories (${categories.length})",
                                style: const TextStyle(
                                    color: Color(0xFF989898),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700),
                              ),
                              GestureDetector(
                                onTap: () => showAddForm(context),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Text(
                                        "New Category",
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.add,
                                        size: 16,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            height: 150,
                            child: ListView.separated(
                              itemCount: categories.length,
                              shrinkWrap: true,
                              physics: categories.length > 3 ? null : const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) => CategoryListItem(
                                categoryName: categories[index].name.capitalize(),
                                onEditPressed: () => showEditForm(context, categories[index]),
                                onDeletePressed: () => showDeleteDialog(context, categories[index]),
                              ),
                            ),
                          ),
                          // ---- CATEGORIES ---- //
            
                          const SizedBox(height: 20),
                          
                          // ---- GENERAL ---- //
                          const Text(
                            "General",
                            style: TextStyle(
                                color: Color(0xFF989898),
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ---- NOTIFICATION ---- //
                              InkWell(
                                onTap: () => AppSettings.openNotificationSettings(),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    border: Border.all(color: const Color(0xFFE6E6E6)),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    "Notification",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              // ---- NOTIFICATION ---- //
                              
                              const SizedBox(height: 10),

                              // ---- THEME ---- //
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  border: Border.all(color: const Color(0xFFE6E6E6)),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Theme",
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    DropdownButton<String>(
                                      value: currentTheme.name,
                                      isDense: true,
                                      underline: const SizedBox(),
                                      items: [
                                        DropdownMenuItem(
                                          value: "light",
                                          onTap: () {
                                            MyApp.of(context).changeTheme(ThemeMode.light);
                                            currentTheme = ThemeMode.light;
                                            setState(() {});
                                          },
                                          child: Text(
                                            "Light",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: "dark",
                                          onTap: () {
                                            MyApp.of(context).changeTheme(ThemeMode.dark);
                                            currentTheme = ThemeMode.dark;
                                            setState(() {});
                                          },
                                          child: Text(
                                            "Dark",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: "system",
                                          onTap: () {
                                            MyApp.of(context).changeTheme(ThemeMode.system);
                                            currentTheme = ThemeMode.system;
                                            setState(() {});
                                          },
                                          child: Text(
                                            "System",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                      onChanged: (value) {},
                                    )
                                  ],
                                ),
                              ),
                              // ---- THEME ---- //
                            ],
                          )
                          // ---- GENERAL ---- //
                        ],
                      ),
                      // ---- CONTENT ---- //
                    ],
                  ),
            
            
                  // ---- ABOUT ---- //
                  const Column(
                    children: [
                      Text(
                        "VHarya",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300
                        ),
                      ),
                      Text(
                        "ver 1.0.0",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300
                        ),
                      ),
                    ],
                  )
                  // ---- ABOUT ---- //
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
