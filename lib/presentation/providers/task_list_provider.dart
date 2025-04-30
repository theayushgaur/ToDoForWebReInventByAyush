import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/task_provider.dart';
import '../../domain/entities/task.dart';

class TaskListProvider extends ChangeNotifier {
  List<String> _lists = ['Personal', 'Work', 'Shopping', 'Other'];
  List<String> get lists => _lists;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TaskListProvider() {
    loadLists();
  }

  Future<void> loadLists() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLists = prefs.getStringList('task_lists');

      if (savedLists != null && savedLists.isNotEmpty) {
        _lists = savedLists;
      }
    } catch (e) {
      // Use default lists if there's an error
      _lists = ['Personal', 'Work', 'Shopping', 'Other'];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Ensure any list names from tasks are added to the available lists
  Future<void> syncListsWithTasks(List<Task> tasks) async {
    bool hasChanges = false;
    for (final task in tasks) {
      if (task.listName != null &&
          task.listName!.isNotEmpty &&
          !_lists.contains(task.listName)) {
        _lists.add(task.listName!);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await _saveLists();
      notifyListeners();
    }
  }

  Future<void> addList(String listName) async {
    if (listName.isNotEmpty && !_lists.contains(listName)) {
      _lists.add(listName);
      await _saveLists();
      notifyListeners();
    }
  }

  Future<void> removeList(String listName) async {
    if (_lists.contains(listName) && _lists.length > 1) {
      _lists.remove(listName);
      await _saveLists();
      notifyListeners();
    }
  }

  Future<void> _saveLists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('task_lists', _lists);
    } catch (e) {
      // Handle error
    }
  }
}
