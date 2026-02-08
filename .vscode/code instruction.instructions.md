---
applyTo: "**/*.dart, **/*.ts, **/*.js, **/*.jsx, **/*.tsx, **/*.json, **/*.md, **/*.yaml, **/*.yml, **/*.html"
---
# Project general coding standards

## General Guidelines
### 🔄 Project Awareness & Context

- **Always read `PLANNING.md`** at the start of a new conversation to understand the project's architecture, goals, style, and constraints.

- **Check `TASK.md`** before starting a new task. If the task isn’t listed, add it with a brief description and today's date.

- **Use consistent naming conventions, file structure, and architecture patterns** as described in `PLANNING.md`.


### 🧱 Code Structure & Modularity
- **add comments on every new function or class** explaining its purpose and usage.

- **Never create a file longer than 500 lines of code.** If a file approaches this limit, refactor by splitting it into modules or helper files.

- **Organize code into clearly separated modules**, grouped by feature or responsibility.

- **Use clear, consistent imports** (prefer relative imports within packages).


### 🧪 Testing & Reliability

- **Always used flutter analyze to tests for new features ,edit code** (functions, classes, routes, etc).

- **After updating any logic**, check whether existing unit tests need to be updated. If so, do it.

- **flutter analyze must pass without errors** before submitting code for review.

### ✅ Task Completion

- **Mark completed tasks in `TASK.md`** immediately after finishing them.

- Add new sub-tasks or TODOs discovered during development to `TASK.md` under a “Discovered During Work” section.


### 📎 Style & Conventions
- **Follow the Dart and Flutter style guides**: https://dart.dev/guides/language/effective-dart/style and https://flutter.dev/docs/development/tools/formatting
- **Use a consistent code formatter** (e.g., `dart format` for Dart/Flutter projects).
- **Avoid deep nesting**; refactor code to keep nesting levels to a maximum of 3.


  ```


### 📚 Documentation & Explainability

- **Update `README.md`** when new features are added, dependencies change, or setup steps are modified.

- **Comment non-obvious code** and ensure everything is understandable to a mid-level developer.

- When writing complex logic, **add an inline `# Reason:` comment** explaining the why, not just the what.


### 🧠 AI Behavior Rules

- **Never assume missing context. Ask questions if uncertain.**

- **Never hallucinate libraries or functions** – only use known, verified flutter packages.

- **Always confirm file paths and module names** exist before referencing them in code or tests.

- **Never delete or overwrite existing code** unless explicitly instructed to or if part of a task from `TASK.md`.

## Naming Conventions
- Use PascalCase for component names, interfaces, and type aliases
- Use camelCase for variables, functions, and methods
- Prefix private class members with underscore (_)
- Use ALL_CAPS for constants
- Use meaningful and descriptive names

## Error Handling
- used  context7 mcp for assistance
- Use try/catch blocks for async operations
- Implement proper error boundaries in React components
- Always log errors with contextual information
- Avoid silent failures; always provide feedback to the user
