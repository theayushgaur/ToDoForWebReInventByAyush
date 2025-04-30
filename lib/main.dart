import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/app.dart';
import 'presentation/pages/onboarding_page.dart';
import 'presentation/providers/task_provider.dart';
import 'presentation/providers/task_list_provider.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final taskProvider = TaskProvider();

  await taskProvider.clearAllTasks();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: taskProvider),
        ChangeNotifierProvider(create: (_) => TaskListProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SyncStrive',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const OnboardingPage(),
    );
  }
}
