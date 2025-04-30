class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
  final int subtasksCount;
  final String? listName;
  final String? description;
  final List<String> tags;
  final List<Task> subtasks;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
    this.subtasksCount = 0,
    this.listName,
    this.description,
    this.tags = const [],
    this.subtasks = const [],
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
    int? subtasksCount,
    String? listName,
    String? description,
    List<String>? tags,
    List<Task>? subtasks,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      subtasksCount: subtasksCount ?? this.subtasksCount,
      listName: listName ?? this.listName,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
