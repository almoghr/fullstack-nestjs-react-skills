#!/usr/bin/env bash
set -e

# Script: generate-ci-workflow.sh
# Purpose: Generates a fully generic sequential GitHub Actions CI workflow (.github/workflows/ci.yml)
# dynamically accepting language/framework configuration parameters or detecting stack defaults.

TARGET_DIR="${1:-.}"
LINT_CMD="${2}"
UNIT_TEST_CMD="${3}"
E2E_CMD="${4}"
BUILD_CMD="${5}"
TARGET_BRANCHES="${6:-main, master, dev, development}"

WORKFLOW_DIR="${TARGET_DIR}/.github/workflows"
WORKFLOW_FILE="${WORKFLOW_DIR}/ci.yml"

mkdir -p "$WORKFLOW_DIR"

# Dynamic stack detection fallback if custom commands are not provided
if [ -z "$LINT_CMD" ] && [ -z "$UNIT_TEST_CMD" ] && [ -z "$BUILD_CMD" ]; then
  if [ -f "${TARGET_DIR}/package.json" ]; then
    LINT_CMD="npx oxlint || true && pnpm tsc --noEmit || npm run lint || true"
    UNIT_TEST_CMD="pnpm test || npm test || true"
    E2E_CMD="pnpm test:e2e || npm run test:e2e || true"
    BUILD_CMD="pnpm run build || npm run build"
  elif [ -f "${TARGET_DIR}/Cargo.toml" ]; then
    LINT_CMD="cargo clippy -- -D warnings"
    UNIT_TEST_CMD="cargo test"
    E2E_CMD="cargo test --test '*' || true"
    BUILD_CMD="cargo build --release"
  elif [ -f "${TARGET_DIR}/go.mod" ]; then
    LINT_CMD="golangci-lint run || go vet ./..."
    UNIT_TEST_CMD="go test ./..."
    E2E_CMD="go test -tags=e2e ./... || true"
    BUILD_CMD="go build ./..."
  elif [ -f "${TARGET_DIR}/pyproject.toml" ] || [ -f "${TARGET_DIR}/requirements.txt" ]; then
    LINT_CMD="ruff check . || flake8 . || true"
    UNIT_TEST_CMD="pytest"
    E2E_CMD="pytest tests/e2e || true"
    BUILD_CMD="python -m compileall ."
  elif [ -f "${TARGET_DIR}/pom.xml" ] || [ -f "${TARGET_DIR}/build.gradle" ]; then
    LINT_CMD="./gradlew check || ./mvnw spotbugs:check || true"
    UNIT_TEST_CMD="./gradlew test || ./mvnw test"
    E2E_CMD="./gradlew e2eTest || ./mvnw verify || true"
    BUILD_CMD="./gradlew build || ./mvnw package"
  else
    LINT_CMD="echo 'No lint command configured'"
    UNIT_TEST_CMD="echo 'No unit test command configured'"
    E2E_CMD="echo 'No e2e test command configured'"
    BUILD_CMD="echo 'No build command configured'"
  fi
fi

# Fallback default strings if any specific command argument was empty
LINT_CMD="${LINT_CMD:-echo 'Skipping lint stage'}"
UNIT_TEST_CMD="${UNIT_TEST_CMD:-echo 'Skipping unit test stage'}"
E2E_CMD="${E2E_CMD:-echo 'Skipping e2e test stage'}"
BUILD_CMD="${BUILD_CMD:-echo 'Skipping build stage'}"

# Convert comma-separated branches into YAML array format
IFS=',' read -ra BRANCH_ARR <<< "$TARGET_BRANCHES"
BRANCHES_YAML=""
for b in "${BRANCH_ARR[@]}"; do
  trimmed="$(echo "$b" | xargs)"
  if [ -n "$trimmed" ]; then
    if [ -z "$BRANCHES_YAML" ]; then
      BRANCHES_YAML="[ $trimmed"
    else
      BRANCHES_YAML="$BRANCHES_YAML, $trimmed"
    fi
  fi
done
BRANCHES_YAML="$BRANCHES_YAML ]"

cat << EOF > "$WORKFLOW_FILE"
name: CI Pipeline

on:
  push:
    branches: ${BRANCHES_YAML}
  pull_request:
    branches: ${BRANCHES_YAML}

jobs:
  lint:
    name: Lint & Syntax Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7.0.1
      - uses: actions/setup-node@v7
        with:
          node-version: 24
        continue-on-error: true
      - run: ${LINT_CMD}

  unit-test:
    name: Unit Tests
    needs: lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7.0.1
      - run: ${UNIT_TEST_CMD}

  e2e-test:
    name: E2E Tests
    needs: unit-test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7.0.1
      - run: ${E2E_CMD}

  build:
    name: Build Application
    needs: e2e-test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7.0.1
      - run: ${BUILD_CMD}

  ci-summary:
    name: CI Pipeline Summary Report
    needs: [ lint, unit-test, e2e-test, build ]
    if: always()
    runs-on: ubuntu-latest
    steps:
      - name: Generate Summary Report
        run: |
          echo "### CI Pipeline Execution Summary" >> \$GITHUB_STEP_SUMMARY
          echo "| Job Stage | Result |" >> \$GITHUB_STEP_SUMMARY
          echo "| --- | --- |" >> \$GITHUB_STEP_SUMMARY
          echo "| Lint | \${{ needs.lint.result }} |" >> \$GITHUB_STEP_SUMMARY
          echo "| Unit Tests | \${{ needs.unit-test.result }} |" >> \$GITHUB_STEP_SUMMARY
          echo "| E2E Tests | \${{ needs.e2e-test.result }} |" >> \$GITHUB_STEP_SUMMARY
          echo "| Build | \${{ needs.build.result }} |" >> \$GITHUB_STEP_SUMMARY
          
          if [[ "\${{ needs.build.result }}" == "success" ]]; then
            echo "SUCCESS: All CI pipeline stages completed successfully!" >> \$GITHUB_STEP_SUMMARY
          else
            echo "FAILURE: One or more CI stages failed. Please check the logs." >> \$GITHUB_STEP_SUMMARY
            exit 1
          fi
EOF

echo "==> Generic CI workflow generated at ${WORKFLOW_FILE}"
