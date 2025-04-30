import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/app.dart';
import 'presentation/pages/onboarding_page.dart';
import 'presentation/providers/task_provider.dart';
import 'presentation/providers/task_list_provider.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create the TaskProvider instance
  final taskProvider = TaskProvider();

  // Clear all existing tasks on app start
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Organic Mind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const OnboardingPage(),
    );
  }
}
