-- Add columns to support linking suggestions to existing tasks
alter table public.ai_suggestions 
add column related_todo_id uuid references public.todos(id) on delete set null,
add column action_type text default 'create'; -- 'create' or 'complete'
