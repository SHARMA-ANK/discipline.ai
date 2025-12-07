import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Initialize Supabase Client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    // 2. Get User from Auth Header
    const {
      data: { user },
    } = await supabaseClient.auth.getUser()

    if (!user) {
      return new Response('Unauthorized', { status: 401 })
    }

    // 2.5 Clear old pending suggestions to ensure freshness
    await supabaseClient
      .from('ai_suggestions')
      .update({ status: 'dismissed' })
      .eq('user_id', user.id)
      .eq('status', 'pending')

    // 3. Fetch Context (History & Current Todos)
    const { data: history } = await supabaseClient
      .from('task_history')
      .select('task_title, completed_at')
      .eq('user_id', user.id)
      .order('completed_at', { ascending: false })
      .limit(20)

    const { data: currentTodos } = await supabaseClient
      .from('todos')
      .select('id, title, due_date')
      .eq('user_id', user.id)
      .eq('is_completed', false)

    // 4. Construct the Prompt for Gemini
    const prompt = `
    You are DisciplineAI, a strict but helpful productivity coach.
    
    User Context:
    - Current Date: ${new Date().toISOString()}
    - Recent History: ${JSON.stringify(history)}
    - Active Tasks: ${JSON.stringify(currentTodos)}

    Task:
    1. Analyze the history for patterns.
    2. Check Active Tasks. If an important task is overdue or urgent, suggest completing it.
    3. If no urgent active tasks, suggest new tasks based on history/habits.
    
    Output Format (JSON only):
    {
      "suggestions": [
        {
          "task": "Task Title",
          "reasoning": "Why you suggested this",
          "action": "create" OR "complete",
          "related_todo_id": "UUID of the active task if action is 'complete', otherwise null"
        }
      ]
    }
    `

    // 5. Call Google Gemini API
    const apiKey = Deno.env.get('GEMINI_API_KEY');
    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          contents: [{
            parts: [{ text: prompt }]
          }],
          generationConfig: {
            response_mime_type: "application/json"
          }
        }),
      }
    )

    if (!geminiResponse.ok) {
      const errorText = await geminiResponse.text();
      throw new Error(`Gemini API Error: ${errorText}`);
    }

    const aiData = await geminiResponse.json()
    const content = aiData.candidates?.[0]?.content?.parts?.[0]?.text
    
    if (!content) {
      throw new Error('No content returned from Gemini');
    }

    const parsed = JSON.parse(content)

    // 6. Save Suggestions to Database
    const suggestionsToInsert = parsed.suggestions.map((s: any) => ({
      user_id: user.id,
      suggested_task: s.task,
      reasoning: s.reasoning,
      status: 'pending',
      action_type: s.action || 'create',
      related_todo_id: s.related_todo_id || null
    }))

    if (suggestionsToInsert.length > 0) {
      await supabaseClient.from('ai_suggestions').insert(suggestionsToInsert)
    }

    return new Response(JSON.stringify({ success: true, data: suggestionsToInsert }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
