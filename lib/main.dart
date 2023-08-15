import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:remind_u/widget/bottom_modal/reminder_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:remind_u/model/category.dart';
import 'package:remind_u/model/reminder.dart';
import 'package:remind_u/pages/home.dart';

Future initDatabase() async {
  final prefs = await SharedPreferences.getInstance();
  final firstRun = prefs.getBool("firstRun");
  
  if (firstRun != null || firstRun == false) {
    return;
  }

  final dir = await getApplicationDocumentsDirectory();
  Isar isar = await Isar.open(
    [ReminderSchema, CategorySchema],
    directory: dir.path,
  );

  await isar.writeTxn(() async {
    await isar.categorys.putAll([
      Category("General"),
      Category("Personal"),
      Category("Work"),
    ]);
  });

  await prefs.setBool("firstRun", true);
  
  return;
}

Future initNotifications() async {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'normal-reminder',
        channelName: 'Normal Reminder',
        channelDescription: "Reminders with normal priority",
      ),
      NotificationChannel(
        channelKey: 'pinned-reminder',
        channelName: 'Pinned Reminder',
        channelDescription: "Reminders with high priority",
      ),
    ],
  );
}

Future initializeApp() async {
  await initDatabase();
  await initNotifications();
}

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  initializeApp().then((value) => FlutterNativeSplash.remove());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
  
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static _MyAppState of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  int? notifReminderID;
  String mode = "system";

  Future getMode() async {
    final prefs = await SharedPreferences.getInstance();
    mode = prefs.getString("themeMode") ?? "system";
    
    for (var value in ThemeMode.values) {
      if (value.name == mode) {
        _themeMode = value;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    getMode().then(
      (value) => setState(() {})
    );

    AwesomeNotifications().isNotificationAllowed().then((value) {
      if (!value) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      } else {
        AwesomeNotifications().actionStream.listen((ReceivedAction event) {
          notifReminderID = int.parse(event.payload!["reminder_id"]!);
          setState(() {});
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => HomePage(showReminderWithID: notifReminderID))
          // );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: MyApp.navigatorKey,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => SafeArea(
        child: child ??
        const Scaffold(
          body: Center(child: Text("(builder-fail) Failed to build page")),
        )
      ),
      home: HomePage(showReminderWithID: notifReminderID ?? null),
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF333333),
        scaffoldBackgroundColor: Colors.grey[50],
        cardColor: Colors.grey[50],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.grey[100],
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        cardColor: Colors.grey[100],
      ),
    );
  }

  ThemeMode currentThemeMode() => _themeMode;
  void changeTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("themeMode", themeMode.name);

    mode = themeMode.name;
    setState(() => _themeMode = themeMode);
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension DatetimeExtension on DateTime {
  String customFormat() {
    DateTime now = DateTime.now();
    now = DateTime(now.year, now.month, now.day);
    DateTime inputDate = DateTime(this.year, this.month, this.day);

    int dateDifference = inputDate.difference(now).inDays;
    String time = "${this.hour.toString().padLeft(2, '0')}:${this.minute.toString().padLeft(2, '0')}";

    
    if (dateDifference == -1) {
      return "Yesterday, $time";
    }
    if (dateDifference == 0) {
      return "Today, $time";
    }
    if (dateDifference == 1) {
      return "Tommorow, $time";
    }
    if (dateDifference < -7 && dateDifference >= -14) {
      return "A week ago";
    }
    if (dateDifference < -30 && dateDifference >= -60) {
      return "A month ago";
    }
    if (difference(now).inDays < -60) {
      return "A long time ago";
    }

    String day = this.day.toString().padLeft(2, '0');
    String month = this.month.toString().padLeft(2, '0');
    String year = this.year.toString();

    String hour = this.hour.toString().padLeft(2, '0');
    String minute = this.minute.toString().padLeft(2, '0');

    return "$day/$month/$year $hour:$minute";
  }
}

