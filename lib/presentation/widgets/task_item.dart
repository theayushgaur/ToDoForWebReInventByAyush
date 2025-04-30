import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onToggle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppTheme.radiusMedium,
        side: BorderSide(
          color: task.isCompleted
              ? AppTheme.borderColor.withOpacity(0.5)
              : AppTheme.borderColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      color: task.isCompleted ? AppTheme.backgroundColor : AppTheme.cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.radiusMedium,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (_) => onToggle(),
              shape: RoundedRectangleBorder(
                borderRadius: AppTheme.radiusSmall,
              ),
              activeColor: AppTheme.successColor,
              side: BorderSide(
                color: task.isCompleted
                    ? AppTheme.successColor
                    : AppTheme.borderColor,
                width: 1.5,
              ),
            ),
            title: Text(
              task.title,
              style: AppTheme.bodyLarge.copyWith(
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted
                    ? AppTheme.textLightColor
                    : AppTheme.textDarkColor,
                fontWeight:
                    task.isCompleted ? FontWeight.normal : FontWeight.w500,
              ),
            ),
            subtitle: task.description != null && task.description!.isNotEmpty
                ? Text(
                    task.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textLightColor,
                    ),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (task.dueDate != null ||
                    task.subtasksCount > 0 ||
                    task.listName != null)
                  _buildTaskMetadata(),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.textLightColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskMetadata() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (task.dueDate != null) ...[
          _buildMetadataChip(
            icon: Icons.calendar_today,
            text: DateFormat('dd-MM-yy').format(task.dueDate!),
            color: _isOverdue() ? AppTheme.errorColor : AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
        ],
        if (task.subtasksCount > 0) ...[
          _buildMetadataChip(
            icon: Icons.check_circle_outline,
            text: "${task.subtasksCount} Subtasks",
            color: AppTheme.infoColor,
          ),
          const SizedBox(width: 8),
        ],
        if (task.listName != null && task.listName!.isNotEmpty) ...[
          _buildMetadataChip(
            icon: Icons.folder_outlined,
            text: task.listName!,
            color: AppTheme.accentColor,
          ),
        ],
      ],
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppTheme.radiusSmall,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTheme.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _isOverdue() {
    if (task.dueDate == null) return false;
    return task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted;
  }
}
