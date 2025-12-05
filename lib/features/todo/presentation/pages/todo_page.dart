import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/supabase_todo_repository.dart';
import '../controllers/todo_controller.dart';
import '../widgets/todo_item.dart';
import '../widgets/add_todo_sheet.dart';
import '../widgets/date_timeline.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../ai/presentation/widgets/ai_suggestions_sheet.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject dependencies (In a real app, use Bindings)
    // Using SupabaseTodoRepository instead of MockTodoRepository
    final controller = Get.put(
      TodoController(
        repository: SupabaseTodoRepository(Supabase.instance.client),
      ),
    );
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DISCIPLINE.AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology, color: AppColors.primary),
            tooltip: 'AI Coach',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AiSuggestionsSheet(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(
            () => DateTimeline(
              selectedDate: controller.selectedDate.value,
              onDateSelected: controller.selectDate,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final todos = controller.todosForSelectedDate;
              if (todos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 64,
                        color: AppColors.textSecondary.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No tasks for this day.\nStay disciplined.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return TodoItem(
                    todo: todo,
                    onToggle: () => controller.toggleTodo(todo),
                    onDelete: () => controller.deleteTodo(todo.id),
                    onEdit: () => _showEditDialog(context, todo, controller),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddTodoSheet(onAdd: controller.addTodo),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    dynamic todo,
    TodoController controller,
  ) {
    final textController = TextEditingController(text: todo.title);
    Get.defaultDialog(
      title: 'Edit Task',
      titleStyle: const TextStyle(color: AppColors.primary),
      backgroundColor: AppColors.surface,
      content: TextField(
        controller: textController,
        autofocus: true,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: const InputDecoration(
          hintText: 'Task name',
          hintStyle: TextStyle(color: AppColors.textSecondary),
        ),
      ),
      textConfirm: 'Save',
      textCancel: 'Cancel',
      confirmTextColor: AppColors.onPrimary,
      cancelTextColor: AppColors.textSecondary,
      buttonColor: AppColors.primary,
      onConfirm: () {
        if (textController.text.trim().isNotEmpty) {
          controller.updateTodoTitle(todo.id, textController.text.trim());
          Get.back();
        }
      },
    );
  }
}
