---
name: Setup CI Workflow
description: Generates a fully generic sequential GitHub Actions CI workflow (.github/workflows/ci.yml) supporting any language or framework (Node, Rust, Go, Python, Java, etc.) with queued stages (Lint -> Unit Test -> E2E Test -> Build -> Summary Report).
---

# Setup CI Workflow Skill

Use this skill to configure GitHub Actions CI pipelines for any project regardless of language or framework.

## Sequential Queue & Pipeline Order

The CI pipeline runs stages sequentially in a strict queue (`needs` dependency chain):
1. **Lint & Syntax Check**
2. **Unit Tests** (depends on `lint`)
3. **E2E Tests** (depends on `unit-test`)
4. **Build Application** (depends on `e2e-test`)
5. **CI Summary Report** (depends on all previous stages, generates GitHub Step Summary report)

---

## 1. Always Verify & Use Latest GitHub Action Versions (MANDATORY)

Before generating any CI workflow:
- **Always use the latest action releases & Node runtimes**:
  - `actions/checkout@v7.0.1` (or latest v7 release)
  - `actions/setup-node@v7` (or latest v7 release)
  - Node.js runtime version **`24`** (Node 20 is deprecated on runner environments)
- **Do not use outdated major action versions** (e.g., `v4` or `v6`) or deprecated Node runtimes (`20`).

---

## 2. Branch Detection & Clarification Workflow (MANDATORY)

Before generating the workflow:
1. **Check Existing Local & Remote Branches**:
   ```bash
   git branch -a
   ```
2. **Ask the User**:
   - Inform the user of detected branches (e.g. `main`, `master`, `dev`, `development`, `staging`).
   - Ask: *Which branches should trigger CI builds on push and pull requests?* (Default: `main`).

---

## 2. Generic Command Invocation

Run the generic workflow generation script passing custom commands and target branches:

```bash
.agents/skills/setup-ci-workflow/scripts/generate-ci-workflow.sh <target_dir> [lint_cmd] [unit_test_cmd] [e2e_cmd] [build_cmd] [target_branches]
```

### Examples:
- **Node / React / NestJS with Custom Branches**:
  ```bash
  .agents/skills/setup-ci-workflow/scripts/generate-ci-workflow.sh ./my-app "pnpm oxlint" "pnpm test" "pnpm test:e2e" "pnpm build" "main, dev, development"
  ```
- **Rust with Default Main & Dev Branches**:
  ```bash
  .agents/skills/setup-ci-workflow/scripts/generate-ci-workflow.sh ./my-rust-app "cargo clippy" "cargo test" "cargo test --test '*'" "cargo build --release" "main, dev"
  ```
- **Go**:
  ```bash
  .agents/skills/setup-ci-workflow/scripts/generate-ci-workflow.sh ./my-go-app "go vet ./..." "go test ./..." "go test -tags=e2e ./..." "go build ./..."
  ```
- **Auto-Detect Fallback**:
  ```bash
  .agents/skills/setup-ci-workflow/scripts/generate-ci-workflow.sh ./my-app
  ```

---

## Verification & Commit

After generating `.github/workflows/ci.yml`:
1. Commit the workflow file:
   ```bash
   git add .github/workflows/ci.yml
   git commit -m "ci: add generic sequential CI pipeline"
   ```
2. Push to GitHub to trigger CI on `main`/`master` or Pull Requests.
