import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import '../providers/task_list_provider.dart';
import '../theme/app_theme.dart';

class TaskDetailPage extends StatelessWidget {
  final Task? task;
  final Function(Task task) onSave;
  final VoidCallback? onDelete;

  const TaskDetailPage({
    Key? key,
    this.task,
    required this.onSave,
    this.onDelete,
  }) : super(key: key);

  bool _isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    return dueDate.isBefore(DateTime.now()) &&
        dueDate.day != DateTime.now().day;
  }

  @override
  Widget build(BuildContext context) {
    // Create controllers and initialize task data
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController subtaskController = TextEditingController();

    final isEditing = task != null;

    // Use a stateManager to track mutable state
    final TaskDetailStateManager stateManager = TaskDetailStateManager(
      task: task,
    );

    // Initialize controllers
    titleController.text = stateManager.editedTask.title;
    descriptionController.text = stateManager.editedTask.description ?? '';

    // Sync list if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (stateManager.listName != null && stateManager.listName!.isNotEmpty) {
        final listProvider =
            Provider.of<TaskListProvider>(context, listen: false);
        listProvider.addList(stateManager.listName!);
      }
    });

    void saveChanges() {
      if (titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a task title'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final updatedTask = stateManager.editedTask.copyWith(
        title: titleController.text,
        description: descriptionController.text,
        listName: stateManager.listName,
        dueDate: stateManager.dueDate,
        tags: stateManager.tags,
        subtasks: stateManager.subtasks,
        subtasksCount: stateManager.subtasks.length,
        createdAt: stateManager.editedTask.createdAt ?? DateTime.now(),
      );

      onSave(updatedTask);
    }

    void addTag(String tag) {
      if (tag.isNotEmpty && !stateManager.tags.contains(tag)) {
        stateManager.addTag(tag);
      }
    }

    void addSubtask() {
      if (subtaskController.text.trim().isEmpty) return;

      final subtaskId = 'subtask_${Random().nextInt(10000)}';
      final newSubtask = Task(
        id: subtaskId,
        title: subtaskController.text.trim(),
        createdAt: DateTime.now(),
      );

      stateManager.addSubtask(newSubtask);
      subtaskController.clear();
    }

    Future<void> selectDate(BuildContext context) async {
      final initialDate = stateManager.dueDate ?? DateTime.now();
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppTheme.primaryColor,
                onPrimary: AppTheme.textDarkColor,
                surface: AppTheme.cardColor,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && picked != stateManager.dueDate) {
        stateManager.setDueDate(picked);
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Task' : 'New Task',
          style: AppTheme.headingMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: AnimatedBuilder(
          animation: stateManager,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusMedium,
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: titleController,
                            style: AppTheme.headingSmall,
                            decoration: InputDecoration(
                              hintText: 'Task title',
                              hintStyle: AppTheme.headingSmall
                                  .copyWith(color: AppTheme.textLightColor),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 12),
                            ),
                          ),
                          const Divider(height: 24),
                          TextField(
                            controller: descriptionController,
                            maxLines: 5,
                            style: AppTheme.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'Add description...',
                              hintStyle: AppTheme.bodyMedium
                                  .copyWith(color: AppTheme.textLightColor),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusMedium,
                    ),
                    elevation: 0,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.folder_outlined,
                              color: AppTheme.accentColor),
                          title: const Text('List', style: AppTheme.label),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          trailing: Consumer<TaskListProvider>(
                            builder: (context, listProvider, child) {
                              final availableLists = listProvider.lists;
                              if (stateManager.listName != null &&
                                  !availableLists
                                      .contains(stateManager.listName)) {
                                listProvider.addList(stateManager.listName!);
                              }

                              if (stateManager.listName == null &&
                                  availableLists.isNotEmpty) {
                                stateManager.setListName(availableLists[0]);
                              } else if (stateManager.listName == null) {
                                stateManager.setListName('Personal');
                              }

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentLightColor,
                                  borderRadius: AppTheme.radiusMedium,
                                ),
                                child: DropdownButton<String>(
                                  value: stateManager.listName,
                                  icon: const Icon(Icons.keyboard_arrow_down,
                                      size: 16),
                                  elevation: 4,
                                  underline: Container(height: 0),
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.accentColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  onChanged: (String? newValue) {
                                    stateManager.setListName(newValue!);
                                  },
                                  items: availableLists
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                        ),
                        const Divider(indent: 56, height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.calendar_today,
                            color: stateManager.dueDate != null
                                ? _isOverdue(stateManager.dueDate)
                                    ? AppTheme.errorColor
                                    : AppTheme.primaryColor
                                : AppTheme.textMediumColor,
                          ),
                          title: const Text('Due Date', style: AppTheme.label),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          trailing: GestureDetector(
                            onTap: () => selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: stateManager.dueDate != null
                                    ? (_isOverdue(stateManager.dueDate)
                                        ? AppTheme.errorColor.withOpacity(0.1)
                                        : AppTheme.primaryColor
                                            .withOpacity(0.1))
                                    : AppTheme.backgroundColor,
                                borderRadius: AppTheme.radiusMedium,
                                border: stateManager.dueDate == null
                                    ? Border.all(color: AppTheme.borderColor)
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    stateManager.dueDate != null
                                        ? DateFormat('MMM d, yyyy')
                                            .format(stateManager.dueDate!)
                                        : 'Add date',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: stateManager.dueDate != null
                                          ? (_isOverdue(stateManager.dueDate)
                                              ? AppTheme.errorColor
                                              : AppTheme.primaryColor)
                                          : AppTheme.textMediumColor,
                                      fontWeight: stateManager.dueDate != null
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    stateManager.dueDate != null
                                        ? Icons.edit
                                        : Icons.add,
                                    size: 16,
                                    color: stateManager.dueDate != null
                                        ? (_isOverdue(stateManager.dueDate)
                                            ? AppTheme.errorColor
                                            : AppTheme.primaryColor)
                                        : AppTheme.textMediumColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusMedium,
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.label_outline,
                                      color: AppTheme.warningColor),
                                  const SizedBox(width: 12),
                                  const Text('Tags', style: AppTheme.label),
                                ],
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      String newTag = '';
                                      return AlertDialog(
                                        title: const Text('Add Tag'),
                                        content: TextField(
                                          autofocus: true,
                                          onChanged: (value) {
                                            newTag = value;
                                          },
                                          decoration: AppTheme.inputDecoration(
                                              'Enter tag name'),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              addTag(newTag);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Add'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Add Tag'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.accentColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppTheme.radiusMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (stateManager.tags.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 32, top: 8, bottom: 8),
                              child: Text(
                                'No tags added yet',
                                style: AppTheme.bodyMedium
                                    .copyWith(color: AppTheme.textLightColor),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(left: 32),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: stateManager.tags.map((tag) {
                                  return Chip(
                                    label: Text(tag),
                                    backgroundColor:
                                        AppTheme.warningColor.withOpacity(0.1),
                                    labelStyle: AppTheme.bodySmall.copyWith(
                                      color: AppTheme.warningColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    deleteIcon:
                                        const Icon(Icons.close, size: 16),
                                    deleteIconColor: AppTheme.warningColor,
                                    onDeleted: () {
                                      stateManager.removeTag(tag);
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusMedium,
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.checklist,
                                  color: AppTheme.infoColor),
                              const SizedBox(width: 12),
                              const Text('Subtasks', style: AppTheme.label),
                              const SizedBox(width: 8),
                              if (stateManager.subtasks.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.infoColor.withOpacity(0.1),
                                    borderRadius: AppTheme.radiusFull,
                                  ),
                                  child: Text(
                                    '${stateManager.subtasks.length}',
                                    style: AppTheme.bodySmall.copyWith(
                                      color: AppTheme.infoColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: subtaskController,
                                  decoration:
                                      AppTheme.inputDecoration('Add subtask'),
                                  onSubmitted: (_) => addSubtask(),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add,
                                    color: AppTheme.infoColor),
                                onPressed: addSubtask,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (stateManager.subtasks.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 32, top: 8, bottom: 8),
                              child: Text(
                                'No subtasks added yet',
                                style: AppTheme.bodyMedium
                                    .copyWith(color: AppTheme.textLightColor),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: stateManager.subtasks.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final subtask = stateManager.subtasks[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundColor,
                                    borderRadius: AppTheme.radiusMedium,
                                    border:
                                        Border.all(color: AppTheme.borderColor),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          stateManager
                                              .toggleSubtaskCompletion(subtask);
                                        },
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: AppTheme.infoColor),
                                            color: subtask.isCompleted
                                                ? AppTheme.infoColor
                                                : Colors.transparent,
                                          ),
                                          child: subtask.isCompleted
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 12,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          subtask.title,
                                          style: TextStyle(
                                            decoration: subtask.isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: subtask.isCompleted
                                                ? AppTheme.textLightColor
                                                : AppTheme.textDarkColor,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close,
                                            size: 16, color: Colors.grey),
                                        onPressed: () {
                                          stateManager.removeSubtask(subtask);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          boxShadow: [AppTheme.smallShadow],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDelete ??
                    () {
                      Navigator.of(context).pop();
                    },
                icon: Icon(
                  task != null ? Icons.delete_outline : Icons.close,
                  size: 20,
                ),
                label: Text(
                  task != null ? 'Delete' : 'Cancel',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: task != null
                      ? AppTheme.errorColor
                      : AppTheme.textMediumColor,
                  side: BorderSide(
                    color: task != null
                        ? AppTheme.errorColor.withOpacity(0.5)
                        : AppTheme.borderColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: saveChanges,
                icon: const Icon(Icons.check, size: 20),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// State manager to handle the mutable state
class TaskDetailStateManager extends ChangeNotifier {
  Task editedTask;
  String? listName;
  DateTime? dueDate;
  List<String> tags;
  List<Task> subtasks;

  TaskDetailStateManager({Task? task})
      : editedTask = task != null
            ? (task.createdAt == null
                ? task.copyWith(createdAt: DateTime.now())
                : task)
            : Task(
                id: 'task_${Random().nextInt(10000)}',
                title: '',
                createdAt: DateTime.now(),
              ),
        listName = task?.listName ?? 'Personal',
        dueDate = task?.dueDate,
        tags = task != null ? List<String>.from(task.tags) : [],
        subtasks = task != null ? List<Task>.from(task.subtasks) : [];

  void setListName(String name) {
    listName = name;
    notifyListeners();
  }

  void setDueDate(DateTime date) {
    dueDate = date;
    notifyListeners();
  }

  void addTag(String tag) {
    tags.add(tag);
    notifyListeners();
  }

  void removeTag(String tag) {
    tags.remove(tag);
    notifyListeners();
  }

  void addSubtask(Task subtask) {
    subtasks.add(subtask);
    notifyListeners();
  }

  void removeSubtask(Task subtask) {
    subtasks.remove(subtask);
    notifyListeners();
  }

  void toggleSubtaskCompletion(Task subtask) {
    final index = subtasks.indexWhere((item) => item.id == subtask.id);
    if (index != -1) {
      subtasks[index] = subtasks[index].copyWith(
        isCompleted: !subtasks[index].isCompleted,
      );
      notifyListeners();
    }
  }
}
