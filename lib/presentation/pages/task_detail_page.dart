import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import '../providers/task_list_provider.dart';
import '../theme/app_theme.dart';

class TaskDetailPage extends StatefulWidget {
  final Task? task; // If null, we're creating a new task
  final Function(Task task) onSave;
  final VoidCallback? onDelete;

  const TaskDetailPage({
    Key? key,
    this.task,
    required this.onSave,
    this.onDelete,
  }) : super(key: key);

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String? _listName;
  late DateTime? _dueDate;
  late List<String> _tags;
  late List<Task> _subtasks;
  late Task _editedTask;
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If editing an existing task, initialize with its values
    if (widget.task != null) {
      _editedTask = widget.task!;
      // If the existing task doesn't have createdAt set, add it now
      if (_editedTask.createdAt == null) {
        _editedTask = _editedTask.copyWith(createdAt: DateTime.now());
      }

      _titleController = TextEditingController(text: _editedTask.title);
      _descriptionController =
          TextEditingController(text: _editedTask.description ?? '');
      _listName = _editedTask.listName;
      _dueDate = _editedTask.dueDate;
      _tags = List<String>.from(_editedTask.tags);
      _subtasks = List<Task>.from(_editedTask.subtasks);

      // Ensure the task's list name is available in the list provider
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_listName != null && _listName!.isNotEmpty) {
          final listProvider =
              Provider.of<TaskListProvider>(context, listen: false);
          listProvider.addList(_listName!);
        }
      });
    } else {
      // Creating a new task with current timestamp
      final taskId = 'task_${Random().nextInt(10000)}';
      _editedTask = Task(
        id: taskId,
        title: '',
        createdAt: DateTime.now(), // Explicitly set creation time
      );
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _listName = 'Personal';
      _dueDate = null;
      _tags = [];
      _subtasks = [];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedTask = _editedTask.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      listName: _listName,
      dueDate: _dueDate,
      tags: _tags,
      subtasks: _subtasks,
      subtasksCount: _subtasks.length,
      createdAt: _editedTask.createdAt ?? DateTime.now(),
    );

    widget.onSave(updatedTask);
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
  }

  void _addSubtask() {
    if (_subtaskController.text.trim().isEmpty) return;

    final subtaskId = 'subtask_${Random().nextInt(10000)}';
    final newSubtask = Task(
      id: subtaskId,
      title: _subtaskController.text.trim(),
      createdAt: DateTime.now(),
    );

    setState(() {
      _subtasks.add(newSubtask);
      _subtaskController.clear();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final initialDate = _dueDate ?? DateTime.now();
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

    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card for title and description
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
                      // Title
                      TextField(
                        controller: _titleController,
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

                      // Description
                      TextField(
                        controller: _descriptionController,
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

              // Card for task options
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusMedium,
                ),
                elevation: 0,
                child: Column(
                  children: [
                    // List Selection
                    ListTile(
                      leading: const Icon(Icons.folder_outlined,
                          color: AppTheme.accentColor),
                      title: const Text('List', style: AppTheme.label),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      trailing: Consumer<TaskListProvider>(
                        builder: (context, listProvider, child) {
                          // Make sure the current listName is in the available lists
                          final availableLists = listProvider.lists;
                          if (_listName != null &&
                              !availableLists.contains(_listName)) {
                            // If not found, add it immediately
                            listProvider.addList(_listName!);
                          }

                          // Default to first list if current is null or empty
                          _listName ??= availableLists.isNotEmpty
                              ? availableLists[0]
                              : 'Personal';

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.accentLightColor,
                              borderRadius: AppTheme.radiusMedium,
                            ),
                            child: DropdownButton<String>(
                              value: _listName,
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  size: 16),
                              elevation: 4,
                              underline: Container(height: 0),
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _listName = newValue!;
                                });
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

                    // Due Date
                    ListTile(
                      leading: Icon(
                        Icons.calendar_today,
                        color: _dueDate != null
                            ? _isOverdue()
                                ? AppTheme.errorColor
                                : AppTheme.primaryColor
                            : AppTheme.textMediumColor,
                      ),
                      title: const Text('Due Date', style: AppTheme.label),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      trailing: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _dueDate != null
                                ? (_isOverdue()
                                    ? AppTheme.errorColor.withOpacity(0.1)
                                    : AppTheme.primaryColor.withOpacity(0.1))
                                : AppTheme.backgroundColor,
                            borderRadius: AppTheme.radiusMedium,
                            border: _dueDate == null
                                ? Border.all(color: AppTheme.borderColor)
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _dueDate != null
                                    ? DateFormat('MMM d, yyyy')
                                        .format(_dueDate!)
                                    : 'Add date',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: _dueDate != null
                                      ? (_isOverdue()
                                          ? AppTheme.errorColor
                                          : AppTheme.primaryColor)
                                      : AppTheme.textMediumColor,
                                  fontWeight: _dueDate != null
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _dueDate != null ? Icons.edit : Icons.add,
                                size: 16,
                                color: _dueDate != null
                                    ? (_isOverdue()
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

              // Tags
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                          _addTag(newTag);
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
                      if (_tags.isEmpty)
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
                            children: _tags.map((tag) {
                              return Chip(
                                label: Text(tag),
                                backgroundColor:
                                    AppTheme.warningColor.withOpacity(0.1),
                                labelStyle: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.warningColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                deleteIconColor: AppTheme.warningColor,
                                onDeleted: () {
                                  setState(() {
                                    _tags.remove(tag);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Subtasks
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          const Icon(Icons.check_circle_outline,
                              color: AppTheme.infoColor),
                          const SizedBox(width: 12),
                          const Text('Subtasks', style: AppTheme.label),
                          const Spacer(),
                          Text(
                            '${_subtasks.length} items',
                            style: AppTheme.bodySmall
                                .copyWith(color: AppTheme.textMediumColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Add Subtask input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _subtaskController,
                              decoration: InputDecoration(
                                hintText: 'Add a subtask...',
                                hintStyle: AppTheme.bodyMedium
                                    .copyWith(color: AppTheme.textLightColor),
                                border: OutlineInputBorder(
                                  borderRadius: AppTheme.radiusMedium,
                                  borderSide: const BorderSide(
                                      color: AppTheme.borderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: AppTheme.radiusMedium,
                                  borderSide: const BorderSide(
                                      color: AppTheme.borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: AppTheme.radiusMedium,
                                  borderSide:
                                      BorderSide(color: AppTheme.infoColor),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: AppTheme.infoColor,
                                  onPressed: _addSubtask,
                                  padding: const EdgeInsets.all(12),
                                ),
                              ),
                              onSubmitted: (_) => _addSubtask(),
                            ),
                          ),
                        ],
                      ),

                      // Subtasks List
                      if (_subtasks.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _subtasks.length,
                          itemBuilder: (context, index) {
                            final subtask = _subtasks[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 0,
                              color: subtask.isCompleted
                                  ? AppTheme.backgroundColor
                                  : AppTheme.cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppTheme.radiusSmall,
                                side: BorderSide(
                                  color: subtask.isCompleted
                                      ? AppTheme.borderColor.withOpacity(0.5)
                                      : AppTheme.borderColor.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                leading: Checkbox(
                                  value: subtask.isCompleted,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _subtasks[index] = subtask.copyWith(
                                        isCompleted: value ?? false,
                                      );
                                    });
                                  },
                                  activeColor: AppTheme.successColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppTheme.radiusSmall,
                                  ),
                                ),
                                title: Text(
                                  subtask.title,
                                  style: AppTheme.bodyMedium.copyWith(
                                    decoration: subtask.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: subtask.isCompleted
                                        ? AppTheme.textLightColor
                                        : AppTheme.textDarkColor,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 20),
                                  color: AppTheme.textLightColor,
                                  onPressed: () {
                                    setState(() {
                                      _subtasks.removeAt(index);
                                    });
                                  },
                                  padding: const EdgeInsets.all(12),
                                  tooltip: 'Delete subtask',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          boxShadow: [AppTheme.smallShadow],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onDelete ??
                    () {
                      Navigator.of(context).pop();
                    },
                icon: Icon(
                  widget.task != null ? Icons.delete_outline : Icons.close,
                  size: 20,
                ),
                label: Text(
                  widget.task != null ? 'Delete' : 'Cancel',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: widget.task != null
                      ? AppTheme.errorColor
                      : AppTheme.textMediumColor,
                  side: BorderSide(
                    color: widget.task != null
                        ? AppTheme.errorColor.withOpacity(0.5)
                        : AppTheme.borderColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Validate title is not empty
                  if (_titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a task title'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  _saveChanges();
                },
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

  bool _isOverdue() {
    if (_dueDate == null) return false;
    final now = DateTime.now();
    return _dueDate!.isBefore(DateTime(now.year, now.month, now.day)) &&
        !_editedTask.isCompleted;
  }
}
