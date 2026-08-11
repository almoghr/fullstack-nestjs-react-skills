---
name: Scaffold NestJS Module
description: Scaffolds a new NestJS module/resource with standard custom subdirectories (dto, constants, repositories, schemas) following project guidelines.
---

# Scaffold NestJS Module Skill

When the user asks you to scaffold a new NestJS module or CRUD resource, follow this structured workflow:

## 1. Schema, Field & Validation Clarification (MANDATORY)
**Do NOT decide or invent schema properties or validation rules on your own.** Before generating schema files, DTOs, services, or repositories:
- Ask the user to define the schema and its properties (field names, data types, required/optional status, default values, unique constraints, and enums).
- **For each property, explicitly ask the user if there are any special validation rules** to enforce (e.g., minimum/maximum length or value, regex patterns, custom email/URL formats, nested arrays validation, or specific `class-validator` rules).
- Wait for the user's input or confirmation on both the schema structure and special validation rules before proceeding to build the module files.

## 2. Verify Nest CLI & Commands
Before generating files, execute the Nest CLI verification script:
```bash
.agents/skills/scaffold-nest-module/scripts/check-nest.sh
```
This script checks Nest CLI options and lists available schematics using `command nest` or `nest generate --help`.

## 3. Resource Generation (`res` schematic by default)
By default, use Nest CLI resource generation or the helper script:
```bash
$ nest generate resource <feature-name>
# or short alias:
$ nest g res <feature-name>
```

Alternatively, run the automated scaffolding tool:
```bash
.agents/skills/scaffold-nest-module/scripts/scaffold-module.sh <feature-name> [backend-path]
```

## 4. Required Custom Directory Structure
Every generated NestJS feature module MUST contain the following custom directory structure under `src/<feature-name>/`:

```
src/<feature-name>/
├── constants/
│   └── <feature-name>.constants.ts
├── dto/
│   ├── create-<singular-name>.dto.ts
│   ├── update-<singular-name>.dto.ts
│   └── <singular-name>-response.dto.ts
├── excel/                               (optional: for Excel export generators)
│   ├── <singular-name>-excel.constants.ts
│   └── <singular-name>-excel.generator.ts
├── repositories/
│   ├── <feature-name>.repository.ts
│   └── <feature-name>.repository.spec.ts
├── schemas/
│   └── <singular-name>.schema.ts
├── <feature-name>.controller.ts
├── <feature-name>.controller.spec.ts
├── <feature-name>.service.ts
├── <feature-name>.service.spec.ts
└── <feature-name>.module.ts
```

## 5. Coding & Architecture Standards
1. **Magic Strings & Numbers**: Strictly forbidden. Define all status messages, default page sizes, and magic values inside `constants/<feature-name>.constants.ts`.
2. **Validation Messages in Constants**: NEVER hardcode validation message strings inside `@Matches()`, `@MinLength()`, or any `class-validator` decorators in DTOs. Define all validation error message strings inside `constants/<feature-name>.constants.ts` (e.g. `FEATURE_VALIDATION_MESSAGES.INVALID_DATE_OF_BIRTH`) and import them into DTO classes.
3. **Excel Column Constants**: Excel columns, header styling, and worksheet configurations MUST NOT be hardcoded inline inside generator/export service files. All Excel worksheet column configurations (headers, keys, widths, styles) MUST be placed inside a dedicated constant file in the `services/` or `excel/` folder (e.g. `services/<singular-name>-excel.constants.ts`).
4. **Schema Document Typing**: Always export document types using `HydratedDocument<Class>` (e.g. `import { HydratedDocument } from 'mongoose'; export type UserDocument = HydratedDocument<User>;`). NEVER use `User & Document`.
5. **Type Safety**: Strictly define interfaces, DTO types, and Mongoose document types. Do NOT use `any`.
6. **Repository Pattern**: Isolate database operations inside `repositories/<feature-name>.repository.ts`.
7. **Mongoose Updates**: Always use `{ returnDocument: 'after' }` option in `findByIdAndUpdate()` or `findOneAndUpdate()` calls instead of deprecated `{ new: true }`.
8. **Validation**: Use `class-validator` and `class-transformer` decorators in `dto/` classes with constants for messages and numeric limits.

## 6. Post-Scaffolding & Quality Assurance Workflow
After scaffolding and editing the code, you MUST execute the required project quality checks:

1. **Type Checking**:
   ```bash
   pnpm tsc --noEmit
   ```
2. **Oxlint**:
   ```bash
   npx oxlint --fix
   ```
3. **Unit Testing**:
   ```bash
   pnpm run test
   ```
4. **API Documentation**:
   - Update the Postman collection under `postman/` with new API endpoints for the module.
   - Run/update Newman tests if configured.

## References & Examples
See the `references/` folder for starter code patterns:
- `references/schema.example.ts`: Mongoose schema pattern with `HydratedDocument`
- `references/constants.example.ts`: Constants pattern including `FEATURE_VALIDATION_MESSAGES`
- `references/repository.example.ts`: Mongoose repository pattern
