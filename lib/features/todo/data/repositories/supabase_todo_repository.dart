import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../models/todo_model.dart';

class SupabaseTodoRepository implements TodoRepository {
  final SupabaseClient _supabase;

  SupabaseTodoRepository(this._supabase);

  @override
  Stream<List<Todo>> getTodos() {
    return _supabase
        .from('todos')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map(
          (data) => data.map<Todo>((json) => TodoModel.fromJson(json)).toList(),
        );
  }

  @override
  Future<void> addTodo(Todo todo) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final model = TodoModel.fromEntity(todo);
    await _supabase.from('todos').insert({
      ...model.toJson(),
      'user_id': user.id,
      // We don't send ID because Supabase generates it,
      // or we can send it if we want client-side generation.
      // For now, let's rely on Supabase UUID generation or use the one we generated.
      // Since our Todo entity has an ID, let's use it.
      'id': todo.id,
    });
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final model = TodoModel.fromEntity(todo);
    await _supabase.from('todos').update(model.toJson()).eq('id', todo.id);

    // If the task is completed, add it to history
    if (todo.isCompleted) {
      await _addToHistory(todo);
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    await _supabase.from('todos').delete().eq('id', id);
  }

  Future<void> _addToHistory(Todo todo) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('task_history').insert({
      'user_id': user.id,
      'task_title': todo.title,
      'completed_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
