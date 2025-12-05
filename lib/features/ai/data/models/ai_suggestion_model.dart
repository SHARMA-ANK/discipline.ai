class AiSuggestionModel {
  final String id;
  final String suggestedTask;
  final String reasoning;
  final String status;
  final String actionType;
  final String? relatedTodoId;

  AiSuggestionModel({
    required this.id,
    required this.suggestedTask,
    required this.reasoning,
    required this.status,
    required this.actionType,
    this.relatedTodoId,
  });

  factory AiSuggestionModel.fromJson(Map<String, dynamic> json) {
    return AiSuggestionModel(
      id: json['id'] as String,
      suggestedTask: json['suggested_task'] as String,
      reasoning: json['reasoning'] as String,
      status: json['status'] as String,
      actionType: json['action_type'] as String? ?? 'create',
      relatedTodoId: json['related_todo_id'] as String?,
    );
  }
}
