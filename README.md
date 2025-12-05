# Reel 1: The Skeleton (Clean Architecture)

**Goal:** Show how to organize a scalable Flutter app using Clean Architecture.

## 🎬 Script & Talking Points

**Hook:** "Stop writing spaghetti code. Here is the Clean Architecture structure I use for scalable Flutter apps."

**Key Concepts:**
1.  **Separation of Concerns:** We divide the app into layers so the UI doesn't know about the Database.
2.  **Scalability:** This structure makes it easy to add new features (like AI) later.

## 📂 Files to Show

Open your file explorer and highlight the `lib/features/todo/` folder.

### 1. Domain Layer (The Logic)
*   **File:** `lib/features/todo/domain/entities/todo.dart`
*   **Explain:** "This is the pure logic. It defines what a 'Todo' is. It has no Flutter UI code and no Database code."

### 2. Data Layer (The Plumbing)
*   **File:** `lib/features/todo/data/repositories/supabase_todo_repository.dart`
*   **Explain:** "This layer handles the dirty work. It talks to Supabase, fetches JSON, and converts it into our Domain entities."

### 3. Presentation Layer (The UI)
*   **File:** `lib/features/todo/presentation/pages/todo_page.dart`
*   **Explain:** "This is what the user sees. It asks the Controller for data and draws it on the screen."

## 🛠️ Technical Setup
*   Ensure you have the `flutter_clean_architecture` or similar folder structure set up.
*   No external dependencies are strictly needed for this reel, just the folder structure.
