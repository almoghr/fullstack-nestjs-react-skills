---
name: Create Page
description: Scaffolds one or more React 19 frontend pages based on user requirements, investigates backend modules or clarifies context, decomposes UI into custom components using the create-componet skill, and ensures strict compliance with project guidelines.
---

# Create Page Skill

When the user asks you to create one or more pages, follow this structured workflow:

---

## 1. Requirement & Scope Clarification

### 1.1 Page Count & Route Hierarchy
- Determine whether a single page or multiple pages / sub-routes need to be created.
- Ask for or determine the target directory for the page(s) (e.g., `polytech-bgf-client/src/pages/<PageName>` or `src/features/<FeatureName>/pages`).

### 1.2 Backend Investigation vs. No-Backend Context
- **Ask the user which backend module needs to be investigated** (e.g., `polytech-bgf-backend/src/<module-name>`).
- **If a backend module is specified**:
  1. Inspect the backend directory:
     - Controller: `src/<module>/<module>.controller.ts` (routes, HTTP methods, status codes)
     - DTOs: `src/<module>/dto/` (request and response structures, field validations)
     - Constants: `src/<module>/constants/` (enums, default values, error messages)
     - Schemas / Entities: `src/<module>/schemas/` (document / entity schemas)
  2. Extract data models, query params, pagination structures, and response DTOs to mirror into frontend TypeScript types.
- **If the user states there is NO backend** (or backend is not ready / standalone UI):
  1. **Ask clarifying questions to understand the complete context**:
     - What is the primary purpose and user flow of the page?
     - What data structures, forms, tables, cards, filters, or views are displayed or manipulated?
     - What user interactions, validations, and state transitions are needed?
     - What mock data or state management approach should be used?
- **Completeness Check**:
  - If the user provides partial or insufficient context, **proactively ask for the missing details** before writing code. Do not make unverified assumptions for critical requirements.

### 1.3 Internationalization (i18n) Clarification
- **Ask the user if internationalization (multi-language translations) is relevant for this page/feature**:
  - **If NO**: Skip multi-language translations and provide/configure keys in **Hebrew (`he.json`)** as the default frontend language.
  - **If YES**: Prompt the user to select or multi-select target languages from the available list:
    - `en` (English)
    - `ar` (Arabic)
    - `de` (German)
    - `es` (Spanish)
    - `fr` (French)
    - `he` (Hebrew)
    - `id` (Indonesian)
    - `pt` (Portuguese)
    - `ru` (Russian)
  - Generate and sync all new translation keys across the selected language files.

---

## 2. Component Decomposition & Custom Component Creation

When designing and building the page:
1. **Break down the page into modular, focused components**.
2. **Identify custom components**: Determine what custom UI building blocks are needed for the page (e.g., `CustomFilterBar`, `CustomDataTable`, `CustomMetricCard`, `CustomDetailModal`, `CustomForm`).
3. **MANDATORY - Use `create-componet` Skill**:
   - For every custom component required to build the page, strictly apply the guidelines from:
     `/Users/almogram/Desktop/projects/polytech/.agents/skills/create-componet/SKILL.md`
   - Follow all custom component rules:
     - Component name MUST be prefixed with `Custom` (e.g., `CustomUserTable`, `CustomMetricCard`).
     - Placed in dedicated directory: `Custom<Name>/`.
     - Required files: `[ComponentName].tsx`, `[ComponentName].module.css`, `[ComponentName].test.tsx`.
     - React 19 standards: direct `ref` prop (no `forwardRef`), `use(Context)` over `useContext`, form actions/`useTransition`, direct `react` imports (no `React.*`).
     - Accessibility (a11y) unit tests using `jest-axe` (`toHaveNoViolations`).

---

## 3. Directory Structure for Pages

For each page (or group of pages), organize files as follows:

```
src/pages/<PageName>/
├── components/                            # Page-specific custom components created via create-componet
│   ├── Custom<SubComponentA>/
│   │   ├── Custom<SubComponentA>.tsx
│   │   ├── Custom<SubComponentA>.module.css
│   │   └── Custom<SubComponentA>.test.tsx
│   └── Custom<SubComponentB>/
│       ├── Custom<SubComponentB>.tsx
│       ├── Custom<SubComponentB>.module.css
│       └── Custom<SubComponentB>.test.tsx
├── constants/
│   └── <page-name>.constants.ts           # Route paths, i18n keys, table headers, default values
├── hooks/
│   └── use<PageName>.ts                   # Data fetching, mutations, local state logic
├── types/
│   └── <page-name>.types.ts               # Frontend interfaces, API DTO types, view models
├── <PageName>Page.tsx                     # Main page component
├── <PageName>Page.module.css              # Page layout styles (CSS Modules only)
└── <PageName>Page.test.tsx                # Page-level integration/unit tests
```

---

## 4. Strict Project Guidelines & Constraints

Every generated page and component MUST follow all project rules without exception:

1. **Styling (CSS Modules Only)**:
   - **NO inline styles**: `style={{ ... }}` is strictly forbidden.
   - Use `.module.css` files and import them as `styles` (`className={styles.container}`).
2. **Internationalization (i18n)**:
   - **NO raw strings**: All user-facing text must use `useTranslation().t('key')`.
   - **Translations Scope**:
     - **If i18n not relevant**: Default to Hebrew (`he.json`) only and skip other locale files.
     - **If i18n relevant**: Add every new translation key to the selected locales from:
       - `en.json` (English)
       - `ar.json` (Arabic)
       - `de.json` (German)
       - `es.json` (Spanish)
       - `fr.json` (French)
       - `he.json` (Hebrew)
       - `id.json` (Indonesian)
       - `pt.json` (Portuguese)
       - `ru.json` (Russian)
3. **No Browser Alerts**:
   - NEVER use `window.alert()`, `window.confirm()`, or `window.prompt()`.
   - Use custom modals or the application alert context (`useAlert().showAlert()`).
4. **Magic Strings & Numbers**:
   - NEVER use magic strings or numbers.
   - Define all routes, limits, labels, default values, query keys, and status codes in `<page-name>.constants.ts`.
5. **React 19 & Imports**:
   - Import types and hooks directly from `react` (e.g., `import { useState, useTransition } from 'react'`, `import type { ReactNode } from 'react'`).
   - NEVER use `React.FC`, `React.useState`, or `import React from 'react'`.
   - Pass `ref` directly as a prop (do not use `forwardRef`).
   - Use `use(Context)` instead of `useContext(Context)`.
6. **Type Safety**:
   - Strictly type all props, states, hooks, and API payloads with TypeScript `interface` / `type`.
   - NEVER use `any` without consulting the developer.
7. **Package Manager**:
   - Always use `pnpm`.

---

## 5. Post-Development Quality Assurance & Verification

After developing the page(s) and components, execute the following quality checks:

1. **Type Checking**:
   ```bash
   pnpm tsc --noEmit
   ```
2. **Oxlint**:
   ```bash
   npx oxlint --fix
   ```
3. **Unit & Component Testing (Vitest / Jest + React Testing Library + a11y)**:
   ```bash
   pnpm test
   ```
4. **End-to-End Testing (Playwright)**:
   - Create or update Playwright e2e test files (e.g., `e2e/<page-name>.spec.ts`) covering key user journeys, page navigation, form submissions, and UI interactions.
   ```bash
   pnpm exec playwright test
   ```
5. **Postman & Newman (if API endpoints created/updated)**:
   - Ensure Postman collection and Newman tests are updated accordingly.

---

## References & Examples
Refer to the following reference templates in the `references/` folder when scaffolding:
- `references/page.tsx.example`: Page component template with React 19 and i18n
- `references/page.module.css.example`: CSS Module layout template
- `references/page.test.tsx.example`: Page integration test template
- `references/page.constants.example.ts`: Constants pattern
- `references/page.types.example.ts`: Type definition pattern
