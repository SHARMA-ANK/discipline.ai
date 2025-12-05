import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/todo.dart';
import '../../../../core/theme/app_colors.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          onTap: onEdit,
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (_) => onToggle(),
            activeColor: AppColors.primary,
            checkColor: AppColors.onPrimary,
            side: const BorderSide(color: AppColors.textSecondary),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              color: todo.isCompleted
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
          ),
          subtitle: todo.dueDate != null
              ? Text(
                  DateFormat('h:mm a').format(todo.dueDate!),
                  style: TextStyle(
                    color: todo.isCompleted
                        ? AppColors.textSecondary.withValues(alpha: 0.5)
                        : AppColors.primary,
                    fontSize: 12,
                  ),
                )
              : null,
          trailing: IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.textSecondary,
            ),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}
