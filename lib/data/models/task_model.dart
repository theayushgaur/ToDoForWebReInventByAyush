import '../../domain/entities/task.dart';

class TaskModel extends Task {
  TaskModel({
    required String id,
    required String title,
    bool isCompleted = false,
    DateTime? dueDate,
    int subtasksCount = 0,
    String? listName,
    String? description,
    List<String> tags = const [],
    List<Task> subtasks = const [],
    DateTime? createdAt,
  }) : super(
          id: id,
          title: title,
          isCompleted: isCompleted,
          dueDate: dueDate,
          subtasksCount: subtasksCount,
          listName: listName,
          description: description,
          tags: tags,
          subtasks: subtasks,
          createdAt: createdAt,
        );

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    try {
      createdAt = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now();
    } catch (e) {
      // Fallback if parsing fails
      createdAt = DateTime.now();
      print('Error parsing createdAt: $e');
    }

    return TaskModel(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      subtasksCount: json['subtasksCount'] ?? 0,
      listName: json['listName'],
      description: json['description'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
      subtasks: json['subtasks'] != null
          ? List<Task>.from(
              json['subtasks'].map((x) => TaskModel.fromJson(x)),
            )
          : const [],
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
      'subtasksCount': subtasksCount,
      'listName': listName,
      'description': description,
      'tags': tags,
      'subtasks': subtasks
          .map((task) => task is TaskModel
              ? task.toJson()
              : TaskModel.fromTask(task).toJson())
          .toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromTask(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      isCompleted: task.isCompleted,
      dueDate: task.dueDate,
      subtasksCount: task.subtasksCount,
      listName: task.listName,
      description: task.description,
      tags: task.tags,
      subtasks: task.subtasks,
      createdAt: task.createdAt,
    );
  }
}
