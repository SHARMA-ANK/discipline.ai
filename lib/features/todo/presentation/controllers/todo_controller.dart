import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';

class TodoController extends GetxController {
  final TodoRepository repository;

  TodoController({required this.repository});

  final RxList<Todo> todos = <Todo>[].obs;
  final RxBool isLoading = true.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    bindTodos();
  }

  void bindTodos() {
    todos.bindStream(repository.getTodos());
    isLoading.value = false;
  }

  List<Todo> get todosForSelectedDate {
    final targetDate = selectedDate.value;
    final filtered = todos.where((todo) {
      if (todo.dueDate == null) return false;
      final todoDate = todo.dueDate!;
      return todoDate.year == targetDate.year &&
          todoDate.month == targetDate.month &&
          todoDate.day == targetDate.day;
    }).toList();

    // Sort by time
    filtered.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    return filtered;
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  Future<void> addTodo(String title, DateTime? dueDate) async {
    if (title.isEmpty) return;

    final newTodo = Todo(
      id: const Uuid().v4(),
      title: title,
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );

    // Optimistic Update: Add to list immediately
    todos.add(newTodo);

    try {
      await repository.addTodo(newTodo);
      // No snackbar needed for success to keep it smooth
    } catch (e) {
      // Revert if failed
      todos.remove(newTodo);
      print('Error adding todo: $e'); // Log to console
      Get.snackbar(
        'Error',
        'Failed to add task: $e',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 5), // Show longer
        snackPosition: SnackPosition.TOP,
      ); // Show at top to be visible
    }
  }

  Future<void> toggleTodo(Todo todo) async {
    // Optimistic Update
    final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
    final index = todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      todos[index] = updatedTodo;
    }

    try {
      await repository.updateTodo(updatedTodo);
    } catch (e) {
      // Revert
      if (index != -1) {
        todos[index] = todo;
      }
      Get.snackbar('Error', 'Failed to update task');
    }
  }

  Future<void> toggleTodoById(String id) async {
    final index = todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      await toggleTodo(todos[index]);
    }
  }

  Future<void> updateTodoTitle(String id, String newTitle) async {
    final index = todos.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final oldTodo = todos[index];
    final updatedTodo = oldTodo.copyWith(title: newTitle);

    // Optimistic Update
    todos[index] = updatedTodo;

    try {
      await repository.updateTodo(updatedTodo);
    } catch (e) {
      // Revert
      todos[index] = oldTodo;
      Get.snackbar('Error', 'Failed to update task');
    }
  }

  Future<void> deleteTodo(String id) async {
    final index = todos.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final todoToDelete = todos[index];

    // Optimistic Update
    todos.removeAt(index);

    try {
      await repository.deleteTodo(id);
    } catch (e) {
      // Revert
      todos.add(todoToDelete);
      Get.snackbar('Error', 'Failed to delete task');
    }
  }
}
