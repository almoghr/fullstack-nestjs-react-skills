---
name: React 19 Validation
description: Validates that React 19 best practices are used and fetches the official React llms.txt documentation when needed.
---

# React 19 Validation Skill

When working with React code in this project or when requested to validate React usage, you must ensure that React 19 features and best practices are utilized. Always refer to the official React documentation for the latest patterns and APIs (such as React Compiler, Actions, `use`, etc.).

## Instructions

1. **Fetch Latest Documentation Context**:
   Run the provided python script to fetch the official React `llms.txt` documentation:
   `python .agents/skills/react_19_validation/scripts/fetch_react_docs.py`

2. **Audit Codebase**:
   Examine React files (e.g. `project/client/src/`) for React 19 anti-patterns and deprecated features:
   - Deprecated `forwardRef` (use standard `ref` prop instead)
   - Superseded `<Context.Provider>` (use `<Context value={...}>` directly)
   - `useContext` usage (prefer `use(Context)` API)
   - Legacy form submit & manual pending states (prefer React 19 Form Actions, `useActionState`, and `useFormStatus`)
   - `useEffect` stale closure cleanups or data fetching anti-patterns
   - Redundant manual memoization (`useMemo`, `useCallback`)

3. **Auto-Update Report File**:
   Whenever a React 19 validation check is performed, **always auto-generate / update the markdown report file** at:
   `planning/react19_validation_report.md`

   Ensure the report lists all detected rejects, file paths with line numbers, code snippets, severity, and proposed React 19 fixes.
