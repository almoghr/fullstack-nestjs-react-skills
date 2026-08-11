---
name: Create Component
description: Scaffolds a new React 19 component with styles, tests, and a11y validation following project best practices.
---

# Create Component Skill

When the user asks you to create a new component, you MUST follow this structured workflow:

## 1. Ask for Target Directory
Before creating any files, you **MUST ask the user** which directory the component should be placed in (e.g., `project/client/src/components/common`). Do not proceed with code generation until you have this information.

## 2. Naming Conventions
- Component name MUST be prefixed with `Custom` (e.g., `CustomCard`, `CustomHeader`).
- The files must be grouped in a dedicated folder named after the component (e.g., `CustomCard/`).
- Required files inside the folder:
  1. `[ComponentName].tsx`
  2. `[ComponentName].module.css`
  3. `[ComponentName].test.tsx`

## 3. Implementation Rules (React 19 & Styling)
- **React 19**: Strictly follow React 19 best practices (no `forwardRef`, use `ref` directly as a prop, use Form actions and `useTransition` instead of manual state for forms, use `use(Context)` instead of `useContext`). Refer to the `React 19 Validation` skill for full guidelines.
- **Styling**: Strictly use CSS Modules (`.module.css`). Inline styles (`style={{...}}`) are strictly forbidden.
- **i18n**: All user-facing text must be translated using `useTranslation().t()`. No raw strings.

## 4. Testing & Accessibility (a11y)
- Tests must be written using Vitest and React Testing Library.
- Every component test suite MUST include an accessibility (a11y) validation using `axe` (e.g., `jest-axe`).
## 5. Never use React.*
- import the type/hook directly from the `react` package
- example: `import type { PropsWithChildren } from 'react'` and `import { useTransition } from 'react'` instead of `import React from 'react'`


## Templates
Reference the following examples in the `references/` folder when scaffolding:
- `references/component.tsx.example`: React 19 Component template
- `references/component.module.css.example`: CSS Module template
- `references/component.test.tsx.example`: Vitest + a11y test template
