-- Create the table for AI suggestions
create table public.ai_suggestions (
  id uuid not null default gen_random_uuid (),
  created_at timestamp with time zone not null default now(),
  user_id uuid not null default auth.uid (),
  suggested_task text not null,
  reasoning text null,
  status text not null default 'pending'::text, -- pending, accepted, dismissed
  constraint ai_suggestions_pkey primary key (id),
  constraint ai_suggestions_user_id_fkey foreign key (user_id) references auth.users (id) on delete cascade
);

-- Enable RLS
alter table public.ai_suggestions enable row level security;

-- Policies
create policy "Users can view their own suggestions" on public.ai_suggestions
  for select using (auth.uid() = user_id);

create policy "Users can insert their own suggestions" on public.ai_suggestions
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own suggestions" on public.ai_suggestions
  for update using (auth.uid() = user_id);
