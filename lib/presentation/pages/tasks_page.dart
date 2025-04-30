import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import '../providers/task_list_provider.dart';
import '../widgets/task_item.dart';
import '../theme/app_theme.dart';
import 'task_detail_page.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.addInitialTasksIfEmpty();

      final listProvider =
          Provider.of<TaskListProvider>(context, listen: false);
      await listProvider.syncListsWithTasks(taskProvider.tasks);
    });

    void openTaskDetail({Task? task}) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TaskDetailPage(
            task: task,
            onSave: (updatedTask) async {
              final provider =
                  Provider.of<TaskProvider>(context, listen: false);

              if (task != null) {
                await provider.updateTask(updatedTask);
              } else {
                await provider.addTask(updatedTask);
              }
              Navigator.of(context).pop();
            },
            onDelete: task != null
                ? () async {
                    final provider =
                        Provider.of<TaskProvider>(context, listen: false);
                    await provider.deleteTask(task.id);
                    Navigator.of(context).pop();
                  }
                : null,
          ),
        ),
      );
    }

    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.tasks;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: Row(
              children: [
                Text(
                  'Today',
                  style: AppTheme.headingMedium,
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentLightColor,
                    borderRadius: AppTheme.radiusFull,
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: AppTheme.textDarkColor),
                onPressed: () {},
                tooltip: 'Search tasks',
              ),
              IconButton(
                icon:
                    const Icon(Icons.more_vert, color: AppTheme.textDarkColor),
                onPressed: () {},
                tooltip: 'More options',
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Card(
                  elevation: 0,
                  color: AppTheme.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusMedium,
                    side: const BorderSide(color: AppTheme.borderColor),
                  ),
                  child: InkWell(
                    onTap: () => openTaskDetail(),
                    borderRadius: AppTheme.radiusMedium,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline,
                              color: AppTheme.accentColor),
                          const SizedBox(width: 12),
                          Text(
                            'Add New Task',
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: taskProvider.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      )
                    : tasks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 80,
                                  color: AppTheme.textLightColor,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No tasks yet!',
                                  style: AppTheme.headingSmall.copyWith(
                                    color: AppTheme.textMediumColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add some tasks to get started.',
                                  textAlign: TextAlign.center,
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textLightColor,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: () => openTaskDetail(),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Create First Task'),
                                  style: AppTheme.primaryButtonStyle,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: tasks.length,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return TaskItem(
                                task: task,
                                onToggle: () =>
                                    taskProvider.toggleTaskStatus(task),
                                onTap: () => openTaskDetail(task: task),
                              );
                            },
                          ),
              ),
            ],
          ),
          floatingActionButton: tasks.isEmpty
              ? null
              : FloatingActionButton(
                  onPressed: () => openTaskDetail(),
                  backgroundColor: AppTheme.primaryColor,
                  child: const Icon(Icons.add, color: AppTheme.textDarkColor),
                ),
        );
      },
    );
  }
}
