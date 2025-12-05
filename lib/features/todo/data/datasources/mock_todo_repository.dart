import 'dart:async';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';

class MockTodoRepository implements TodoRepository {
  final _todosController = StreamController<List<Todo>>.broadcast();
  final List<Todo> _todos = [];

  MockTodoRepository() {
    // Initial mock data
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _todos.addAll([
      Todo(
        id: '1',
        title: 'Setup Flutter Project',
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 1)),
        dueDate: today
            .subtract(const Duration(days: 1))
            .add(const Duration(hours: 10)),
      ),
      Todo(
        id: '2',
        title: 'Design UI Theme',
        isCompleted: true,
        createdAt: now.subtract(const Duration(hours: 5)),
        dueDate: today.add(const Duration(hours: 9)),
      ),
      Todo(
        id: '3',
        title: 'Implement GetX State Management',
        isCompleted: false,
        createdAt: now,
        dueDate: today.add(const Duration(hours: 14)),
      ),
      Todo(
        id: '4',
        title: 'Plan Database Schema',
        isCompleted: false,
        createdAt: now,
        dueDate: today.add(const Duration(days: 1, hours: 10)),
      ),
    ]);
    _emit();
  }

  void _emit() {
    _todosController.add(List.from(_todos));
  }

  @override
  Stream<List<Todo>> getTodos() async* {
    yield List.from(_todos);
    yield* _todosController.stream;
  }

  @override
  Future<void> addTodo(Todo todo) async {
    _todos.add(todo);
    _emit();
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = todo;
      _emit();
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((t) => t.id == id);
    _emit();
  }
}
