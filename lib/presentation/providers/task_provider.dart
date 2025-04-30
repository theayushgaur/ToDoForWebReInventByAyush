import 'package:flutter/foundation.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/update_task.dart';
import '../../data/repositories/task_repository_impl.dart';

class TaskProvider extends ChangeNotifier {
  final _taskRepository = TaskRepositoryImpl();
  late final _getTasks = GetTasks(_taskRepository);
  late final _addTask = AddTask(_taskRepository);
  late final _updateTask = UpdateTask(_taskRepository);
  late final _deleteTask = DeleteTask(_taskRepository);

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _getTasks();

    _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _addTask(task);
      _tasks = await _getTasks();

      _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _updateTask(task);
      _tasks = await _getTasks();

      _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _deleteTask(id);
      _tasks = await _getTasks();

      _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> clearAllTasks() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _taskRepository.clearAllTasks();
      _tasks = [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleTaskStatus(Task task) async {
    try {
      _isLoading = true;
      notifyListeners();
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await _updateTask(updatedTask);
      _tasks = await _getTasks();

      _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addInitialTasksIfEmpty() async {
    try {
      _isLoading = true;
      notifyListeners();
      _tasks = await _getTasks();

      if (_tasks.isNotEmpty) {
        _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading tasks: $e');
    }
  }
}
