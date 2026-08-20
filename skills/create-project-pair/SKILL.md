---
name: Create Project Pair (Client & Backend)
description: Prompts the user for project configuration, creates remote GitHub repositories (<orgName>-client/backend), and scaffolds NestJS backend and React Vite client applications using CLI scripts to minimize token usage.
---

# Create Project Pair Skill

Use this skill when initializing a new project containing both a backend (default: NestJS) and a client frontend (default: React + Vite).

---

## 1. Interactive Clarification Workflow (MANDATORY)

Before executing any script, gather configuration parameters from the user (or confirm default settings):

1. **Organization or Personal**:
   - Ask: *Is this repository inside an GitHub Organization or a Personal account?* (`org` / `user`)
2. **Organization / Account Name**:
   - Ask: *What is the name of the Organization or GitHub user account?* (e.g., `my-org`)
3. **Project Name**:
   - Ask: *What is the base name for the project?* (e.g., `polytech`)
   - Standard naming format applied: `<owner>-<projectName>-client` & `<owner>-<projectName>-backend`
4. **Visibility**:
   - Ask: *Should the repositories be `private` or `public`?* (default: `private`)
5. **Stack & Defaults**:
   - Ask: *Do you want to use the default stack (Backend: NestJS, Client: React + Vite + TS, Package Manager: pnpm)?*
   - If custom: confirm package manager (`pnpm`, `npm`, `yarn`).

---

## 2. GitHub Repositories Setup

Run the optimized repository creation helper script using `gh` CLI:

```bash
.agents/skills/create-project-pair/scripts/create-github-repos.sh <org|user> <owner_name> <project_name> <private|public>
```

*Example:*
```bash
.agents/skills/create-project-pair/scripts/create-github-repos.sh org my-org project-x private
```

---

## 3. Project Scaffolding

Run the non-interactive scaffolding script to generate local codebase structure without generating excessive tokens:

```bash
.agents/skills/create-project-pair/scripts/scaffold-projects.sh <target_dir> <owner_name> <project_name> [package_manager]
```

*Example:*
```bash
.agents/skills/create-project-pair/scripts/scaffold-projects.sh ./ my-org project-x pnpm
```

---

## 4. Post-Setup, CI Workflow & Secrets Integration

After scaffolding completes:
1. **Initialize Local Git Repositories**:
   ```bash
   cd <owner>-<project>-backend && git init && git remote add origin git@github.com:<owner>/<owner>-<project>-backend.git
   cd ../<owner>-<project>-client && git init && git remote add origin git@github.com:<owner>/<owner>-<project>-client.git
   ```

2. **Automated CI Setup (Setup CI Workflow Skill)**:
   Automatically generate sequential GitHub Actions CI pipelines (`Lint -> Unit Test -> E2E Test -> Build -> Summary Report`) by executing:
   ```bash
   .agents/skills/setup-ci-workflow/scripts/generate-ci-workflow.sh <backend_dir>
   .agents/skills/setup-ci-workflow/scripts/generate-ci-workflow.sh <client_dir>
   ```

3. **Repository Secrets (Manage GitHub Secrets Skill)**:
   Ask the user if any environment/repository secrets need to be configured for free-tier orgs, and invoke:
   ```bash
   .agents/skills/manage-github-secrets/scripts/set-repo-secrets.sh <owner/repo> <SECRET_KEY> <SECRET_VALUE>
   ```
   *Note: All secret values MUST be logged as `[REDACTED]` in output.*

4. **Verify Setup**:
   - Check TypeScript compilation (`pnpm tsc --noEmit` if available).
   - Commit and push initial code with `.github/workflows/ci.yml`.
