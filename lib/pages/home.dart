import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remind_u/bloc/home_bloc.dart';
import 'package:remind_u/main.dart';
import 'package:remind_u/model/category.dart';
import 'package:remind_u/model/reminder.dart';
import 'package:remind_u/pages/settings.dart';
import 'package:remind_u/widget/bottom_modal/reminder_detail.dart';
import 'package:remind_u/widget/delete_dialog.dart';

import 'package:remind_u/widget/form/reminder_create.dart';
import 'package:remind_u/widget/form/reminder_edit.dart';
import 'package:remind_u/widget/bottom_modal/more_option.dart';
import 'package:remind_u/widget/normal_reminder.dart';
import 'package:remind_u/widget/pinned_reminder.dart';

class HomePage extends StatefulWidget {
  final int? showReminderWithID;
  const HomePage({super.key, this.showReminderWithID});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Reminder> pinnedReminders = [];
  List<Reminder> normalReminders = [];
  List<Category> categories = [];

  final ScrollController _scrollController = ScrollController();

  double headerBorderWidth = 0;
  Color headerBorderColor = Colors.transparent;
  bool scrollOnTop = true;
  bool isLoading = false;

  int? lastNotifID;
  bool hasShownNotification = false;


  void showDeleteDialog(BuildContext context, Reminder reminder) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (builderContext) => DeleteDialog(
          text: "Are you sure you want to delete this reminder?",
          onCancelPressed: () => Navigator.pop(builderContext),
          onDeletePressed: () {
            Navigator.pop(builderContext);
            BlocProvider.of<HomeBloc>(context).add(DeleteReminder(reminder));
          },
        ),
      );
    });
  }

  void showReminderDetail(BuildContext context, Reminder reminder) {
    final category = categories.firstWhere((element) => element.id == reminder.categoryID);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => ReminderDetail(
          reminder: reminder,
          category: category,
        ),
      ).then((value) {
        if (value == null) return;
        if (value) {
          showOptionDialog(context, reminder);
        }
      });
    });
  }

  void showOptionDialog(BuildContext context, Reminder reminder) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (builderContext) => MoreOptions(
          isPinned: reminder.isPinned,
          onPinPressed: () {
            Navigator.pop(context);
            reminder.isPinned = !reminder.isPinned;
            BlocProvider.of<HomeBloc>(context).add(UpdateReminder(reminder));
          },
          onEditPressed: () {
            Navigator.pop(context);
            showEditForm(context, reminder);
          },
          onDeletePressed: () {
            Navigator.pop(context);
            showDeleteDialog(context, reminder);
          },
        ),
      );
    });
  }

  void showEditForm(BuildContext context, Reminder reminder) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        isScrollControlled: true,
        showDragHandle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        builder: (modalContext) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(modalContext).viewInsets.bottom),
          child: Wrap(
            children: [
              EditReminderDialog(
                reminder: reminder,
                categories: categories,
                onDonePressed: (reminder) {
                  Navigator.pop(context);
                  BlocProvider.of<HomeBloc>(context).add(UpdateReminder(reminder));
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  void setNotifSchedule(Reminder reminder) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random().nextInt(100),
        channelKey: reminder.isPinned ? 'pinned-reminder' : 'normal-reminder',
        title: "A Reminder for you...",
        body: reminder.note.length > 50 ? "${reminder.note.substring(0, 50)}..." : reminder.note,
        wakeUpScreen: true,
        payload: {
          "reminder_id": "${reminder.id}"
        },
      ),
      schedule: NotificationCalendar(
        year: reminder.date.year,
        month: reminder.date.month,
        day: reminder.date.day,
        hour: reminder.date.hour,
        minute: reminder.date.minute,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
  }


  void checkNotifShow() {
    if (widget.showReminderWithID != null) {
      if (widget.showReminderWithID == lastNotifID) return;
      
      Reminder? reminder;
      print("reminder = ${widget.showReminderWithID}");
      
      try {
        reminder = normalReminders.firstWhere(
          (element) => element.id == widget.showReminderWithID,
          orElse: () => pinnedReminders.firstWhere(
            (element) => element.id == widget.showReminderWithID,
          ),
        );
      } catch (e) {
        print("reminder = ${widget.showReminderWithID}");
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Couldn't find said reminder, it may have been deleted..."))
          );
        });
      }

      if (reminder != null) {
        showReminderDetail(context, reminder);
      }

      lastNotifID = widget.showReminderWithID;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          isLoading = false;
          switch (state.runtimeType) {
            case Loading:
              isLoading = true;
              break;
            case HomeInitial:
              BlocProvider.of<HomeBloc>(context).add(Initialize());
              break;
            case InitializeFinished:
              final st = state as InitializeFinished;
              normalReminders = st.data['normal']!;
              pinnedReminders = st.data['pinned']!;
              categories = st.categories;
              checkNotifShow(); //IDGAF Anymore...
              break;
            case GetAllReminderSuccessful:
              final st = state as GetAllReminderSuccessful;
              normalReminders = st.data['normal']!;
              pinnedReminders = st.data['pinned']!;
              break;
            case OperationFailed:
              final st = state as OperationFailed;
              String reason = st.reason;

              WidgetsBinding.instance.addPostFrameCallback(
                (_) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(reason),
                  )
                )
              );
              break;
            case ReloadingData:
              BlocProvider.of<HomeBloc>(context).add(Initialize());
              break;
            case CreateReminderSuccessful:
              final st = state as CreateReminderSuccessful;
              setNotifSchedule(st.reminder);
              BlocProvider.of<HomeBloc>(context).add(ReloadData());
              break;
            default:
          }
          
          return Scaffold(
            resizeToAvoidBottomInset: true,
            floatingActionButton: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: FloatingActionButton.extended(
                onPressed: isLoading ? null : () => showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  isScrollControlled: true,
                  showDragHandle: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  builder: (modalContext) => Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Wrap(
                      children: [
                        NewReminderDialog(
                            categories: categories,
                            onDonePressed: (reminder) {
                              Navigator.pop(context);
                              BlocProvider.of<HomeBloc>(context).add(CreateReminder(reminder));
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                icon: const Icon(Icons.add),
                label: Text(
                  "New Reminder",
                  style: TextStyle(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                )
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---- HEADER ---- //
                Container(
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(
                      bottom: BorderSide(
                        color: headerBorderColor,
                        width: headerBorderWidth
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "RemindU",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      GestureDetector(
                        child: Icon(
                          Icons.settings,
                          color: Theme.of(context).primaryColor,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SafeArea(child: SettingsPage()),
                          ),
                        ).then(
                          (value) => BlocProvider.of<HomeBloc>(context).add(Initialize())
                        ),
                      ),
                    ],
                  ),
                ),
                // ---- HEADER ---- //


                // ---- CONTENT ---- //
                if (isLoading)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Loading...",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ]
                  ),
                ),

                if (!isLoading)
                normalReminders.isEmpty && pinnedReminders.isEmpty ?
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 45,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "No Reminders Yet...",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ) :
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification.metrics.atEdge &&
                          scrollNotification.metrics.pixels == 0) {
                        if (headerBorderWidth != 0) {
                          setState(() {
                            headerBorderColor = Colors.transparent;
                            headerBorderWidth = 0;
                          });
                        }
                      } else {
                        if (headerBorderWidth == 0) {
                          setState(() {
                            headerBorderColor = Colors.black.withOpacity(.2);
                            headerBorderWidth = 2;
                          });
                        }
                      }
                      return true;
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                        child: Column(
                          children: [
                            // ---- PINNED REMINDER ---- //
                            if (pinnedReminders.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Pinned Reminder",
                                  style: TextStyle(
                                      color: Color(0xFF989898),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 5),
                                ListView.separated(
                                  itemCount: pinnedReminders.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    return PinnedReminder(
                                      reminder: pinnedReminders[index],
                                      onPressed: () => showReminderDetail(context, pinnedReminders[index]),
                                      onLongPressed: () => showOptionDialog(context, pinnedReminders[index]),
                                    );
                                  },
                                )
                              ],
                            ),
                            // ---- PINNED REMINDER ---- //

                            if (pinnedReminders.isNotEmpty) const SizedBox(height: 30),

                            // ---- NORMAL REMINDER ---- //
                            if (normalReminders.isNotEmpty)
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: categories.length,
                              padding: const EdgeInsets.only(bottom: 75),
                              separatorBuilder: (context, index) {
                                // Check if this category has reminder
                                List categorizedReminder = normalReminders
                                  .where((element) => element.categoryID == categories[index].id)
                                  .toList();
                                
                                return categorizedReminder.isEmpty ? const SizedBox() : const SizedBox(height: 30);
                              },
                              itemBuilder: (context, index) {
                                // Check if this category has reminder
                                List categorizedReminder = normalReminders
                                  .where((element) => element.categoryID == categories[index].id)
                                  .toList();
                                
                                if (categorizedReminder.isEmpty) {
                                  return const SizedBox();
                                }
                                
                                return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    "${categories[index].name.capitalize()} Reminder",
                                    style: const TextStyle(
                                        color: Color(0xFF989898),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 5),
                                  GridView.count(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: normalReminders
                                      .where((element) => element.categoryID == categories[index].id)
                                      .map((e) => NormalReminder(
                                        reminder: e,
                                        onPressed: () => showReminderDetail(context, e),
                                        onLongPressed: () => showOptionDialog(context, e),
                                      ))
                                      .toList()
                                  )
                                ],
                              );
                              },
                            ),
                            // ---- NORMAL REMINDER ---- //
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // ---- CONTENT ---- //
              ],
            ),
          );
        },
      ),
    );
  }
}
