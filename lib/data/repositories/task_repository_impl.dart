import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';
import 'dart:math';

class TaskRepositoryImpl implements TaskRepository {
  // In-memory cache for tasks
  List<TaskModel> _tasks = [];
  static const String TASKS_STORAGE_KEY = 'tasks_data';

  // Constructor - load tasks from storage
  TaskRepositoryImpl() {
    _loadTasksFromStorage();
  }

  // Load tasks from SharedPreferences
  Future<void> _loadTasksFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(TASKS_STORAGE_KEY);

      if (tasksJson != null) {
        _tasks = tasksJson
            .map((taskJson) => TaskModel.fromJson(jsonDecode(taskJson)))
            .toList();
      }
    } catch (e) {
      print('Error loading tasks: $e');
      _tasks = [];
    }
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTasksToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson =
          _tasks.map((task) => jsonEncode(task.toJson())).toList();

      await prefs.setStringList(TASKS_STORAGE_KEY, tasksJson);
    } catch (e) {
      print('Error saving tasks: $e');
    }
  }

  @override
  Future<List<Task>> getTasks() async {
    // Make sure tasks are loaded from storage
    if (_tasks.isEmpty) {
      await _loadTasksFromStorage();
    }
    return [..._tasks];
  }

  @override
  Future<void> addTask(Task task) async {
    _tasks.add(TaskModel.fromTask(task));
    await _saveTasksToStorage();
  }

  @override
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = TaskModel.fromTask(task);
      await _saveTasksToStorage();
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _saveTasksToStorage();
  }

  @override
  Future<void> clearAllTasks() async {
    _tasks.clear();
    await _saveTasksToStorage();
  }

  // Helper method to generate a unique ID
  String _generateId() {
    return 'task_${Random().nextInt(10000)}';
  }
}
