import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/ai_suggestion_model.dart';
import '../../data/repositories/ai_repository.dart';
import '../../../todo/presentation/controllers/todo_controller.dart';

class AiController extends GetxController {
  final AiRepository _repository = AiRepository(Supabase.instance.client);
  final TodoController _todoController = Get.find<TodoController>();

  var suggestions = <AiSuggestionModel>[].obs;
  var isLoading = false.obs;

  Future<void> fetchSuggestions() async {
    isLoading.value = true;
    try {
      final results = await _repository.getSuggestions();
      suggestions.assignAll(results);
    } catch (e) {
      Get.snackbar('Error', 'Failed to get AI suggestions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptSuggestion(AiSuggestionModel suggestion) async {
    try {
      await _repository.acceptSuggestion(suggestion.id);
      suggestions.remove(suggestion);

      if (suggestion.actionType == 'complete' &&
          suggestion.relatedTodoId != null) {
        // Mark existing task as completed
        await _todoController.toggleTodoById(suggestion.relatedTodoId!);
        Get.snackbar('Completed', 'Task marked as done');
      } else {
        // Add new task
        await _todoController.addTodo(
          suggestion.suggestedTask,
          DateTime.now().add(const Duration(hours: 1)), // Default due in 1 hour
        );
        Get.snackbar('Accepted', 'Task added to your list');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept suggestion');
    }
  }

  Future<void> dismissSuggestion(AiSuggestionModel suggestion) async {
    try {
      await _repository.dismissSuggestion(suggestion.id);
      suggestions.remove(suggestion);
    } catch (e) {
      Get.snackbar('Error', 'Failed to dismiss suggestion');
    }
  }
}
