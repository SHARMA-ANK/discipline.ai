import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ai_suggestion_model.dart';

class AiRepository {
  final SupabaseClient _supabase;

  AiRepository(this._supabase);

  Future<List<AiSuggestionModel>> getSuggestions() async {
    try {
      // Call the Edge Function
      final response = await _supabase.functions.invoke('discipline-coach');

      if (response.status != 200) {
        throw Exception('Failed to fetch suggestions: ${response.status}');
      }

      final data = response.data;

      final List<dynamic> rows = await _supabase
          .from('ai_suggestions')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return rows.map((row) => AiSuggestionModel.fromJson(row)).toList();
    } catch (e) {
      throw Exception('Error fetching AI suggestions: $e');
    }
  }

  Future<void> acceptSuggestion(String id) async {
    await _supabase
        .from('ai_suggestions')
        .update({'status': 'accepted'})
        .eq('id', id);
  }

  Future<void> dismissSuggestion(String id) async {
    await _supabase
        .from('ai_suggestions')
        .update({'status': 'dismissed'})
        .eq('id', id);
  }
}
