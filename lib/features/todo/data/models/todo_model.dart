import '../../domain/entities/todo.dart';

class TodoModel extends Todo {
  TodoModel({
    required super.id,
    required super.title,
    required super.isCompleted,
    required super.createdAt,
    super.dueDate,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'is_completed': isCompleted,
      'created_at': createdAt.toUtc().toIso8601String(),
      if (dueDate != null) 'due_date': dueDate!.toUtc().toIso8601String(),
    };
  }

  factory TodoModel.fromEntity(Todo todo) {
    return TodoModel(
      id: todo.id,
      title: todo.title,
      isCompleted: todo.isCompleted,
      createdAt: todo.createdAt,
      dueDate: todo.dueDate,
    );
  }
}
