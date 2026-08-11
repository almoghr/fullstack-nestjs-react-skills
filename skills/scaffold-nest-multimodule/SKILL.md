---
name: Scaffold NestJS Multi-Module
description: Scaffolds a complex multi-module composite NestJS feature directory containing submodules, enums, types, repositories, schemas, DTOs, schedulers, and auxiliary services following project guidelines.
---

# Scaffold NestJS Multi-Module Skill

When the user asks you to scaffold a complex, multi-module, or composite NestJS feature module (e.g. `business`, `store`, `organization`), follow this structured workflow:

## 1. Requirement & Architecture Clarification (MANDATORY)
**Do NOT decide or invent schema properties, sub-modules, or validation rules on your own.** Before generating any files:
- **Sub-Modules Breakdown**: Ask the user which nested sub-modules should be placed inside `modules/` (e.g., `business-flags`, `business-questions`, `restaurant-questions`).
- **Entity & Schema Properties**: Ask for field names, data types, required/optional status, default values, unique constraints, and domain enums for the parent module and sub-modules.
- **Validation Rules**: Ask if there are specific `class-validator` rules for each DTO field.
- **Auxiliary Requirements**: Ask if the module requires scheduled background tasks (`scheduler/`) or export generators (`services/` like `ExcelService`).
- Wait for user confirmation before proceeding.

## 2. Verify Nest CLI & Commands
Before generating files, execute the Nest CLI verification script:
```bash
.agents/skills/scaffold-nest-multimodule/scripts/check-nest.sh
```

## 3. Multi-Module Scaffolding Execution
To scaffold the composite parent module and its sub-modules, run the automated script:
```bash
.agents/skills/scaffold-nest-multimodule/scripts/scaffold-multi-module.sh <parent-feature-name> [submodules-csv] [backend-path]
```
**Example**:
```bash
.agents/skills/scaffold-nest-multimodule/scripts/scaffold-multi-module.sh business business-flags,business-questions,restaurant-questions polytech-bgf-backend
```

## 4. Required Composite Directory Structure
Every generated multi-module NestJS feature MUST contain the following directory layout under `src/<parent-feature-name>/`:

```
src/<parent-feature-name>/
├── constants/
│   └── <parent-feature-name>.constants.ts
├── dto/
│   ├── create-<singular-name>.dto.ts
│   ├── update-<singular-name>.dto.ts
│   └── <singular-name>-response.dto.ts
├── enums/
│   └── <parent-feature-name>-status.enum.ts
├── modules/                                  # Sub-modules directory
│   ├── <sub-feature-1>/
│   │   ├── dto/
│   │   │   └── create-<singular-sub1>.dto.ts
│   │   ├── repository/
│   │   │   └── <sub-feature-1>.repository.ts
│   │   ├── schemas/
│   │   │   └── <singular-sub1>.schema.ts
│   │   ├── <sub-feature-1>.controller.ts
│   │   ├── <sub-feature-1>.service.ts
│   │   └── <sub-feature-1>.module.ts
│   └── <sub-feature-2>/
│       └── ...
├── repository/
│   └── <parent-feature-name>.repository.ts
├── scheduler/                                # Task schedulers / Crons
│   └── <parent-feature-name>.scheduler.ts
├── schemas/
│   └── <singular-name>.schema.ts
├── services/                                 # Auxiliary domain services (e.g. Excel export)
│   ├── <parent-feature-name>-excel.constants.ts # Excel column definitions & worksheet styling
│   └── export.service.ts
├── types/                                    # Custom domain/response types
│   └── <parent-feature-name>-summary.type.ts
├── <parent-feature-name>.controller.ts
├── <parent-feature-name>.controller.spec.ts
├── <parent-feature-name>.service.ts
├── <parent-feature-name>.service.spec.ts
└── <parent-feature-name>.module.ts
```

## 5. Coding & Architecture Standards
1. **Standard Module Imports (No `forwardRef` by default)**:
   - Always use standard direct module imports in `imports: [SubModule]` and re-export in `exports`.
   - **`forwardRef(() => Module)` is NOT used by default**. It is an incident-specific fallback ONLY to resolve actual circular dependency cycles between two specific modules.
2. **Magic Strings & Numbers**: Strictly forbidden. Define all status messages, validation messages, and defaults in `constants/<parent-feature-name>.constants.ts`.
3. **DTO Validation Messages**: NEVER hardcode validation strings in `@IsString()`, `@IsNotEmpty()`, `@IsEnum()`, etc. Pass constant references (e.g. `FEATURE_VALIDATION_MESSAGES.NAME_REQUIRED`).
4. **Excel Column Constants**: Excel columns, header styling, and worksheet configurations MUST NOT be hardcoded inline inside export services. All Excel column definitions (headers, keys, widths, styles) MUST be placed inside a dedicated constant file in the `services/` folder (e.g. `services/<parent-feature-name>-excel.constants.ts`).
5. **Mongoose Document Typing**: Always export schema document types using `HydratedDocument<Class>` (e.g. `export type BusinessDocument = HydratedDocument<Business>;`). NEVER use `Business & Document`.
6. **Mongoose Updates**: Always use `{ returnDocument: 'after' }` in `findByIdAndUpdate()` or `findOneAndUpdate()` calls.
7. **Strict Type Safety**: Do NOT use `any`.

## 6. Quality Assurance Workflow
After scaffolding and editing code, run:
1. **TypeScript Type Checking**:
   ```bash
   pnpm tsc --noEmit
   ```
2. **Linter & Formatting**:
   ```bash
   npx oxlint --fix
   ```
3. **Unit Tests**:
   ```bash
   pnpm run test
   ```
4. **Postman API Documentation**:
   - Update Postman collections and Newman test configurations under `postman/`.

## References & Examples
See the `references/` directory for code patterns:
- `references/parent-module.example.ts`: Parent module setup with submodules
- `references/sub-module.example.ts`: Sub-module pattern
- `references/scheduler.example.ts`: NestJS Cron / Scheduler pattern
- `references/aux-service.example.ts`: Auxiliary domain service pattern
