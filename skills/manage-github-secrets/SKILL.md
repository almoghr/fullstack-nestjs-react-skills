---
name: Manage GitHub Secrets
description: Sets and manages repository-level secrets on GitHub using gh CLI for free-tier organizations. Prompts for values securely and logs all secrets as [REDACTED].
---

# Manage GitHub Secrets Skill

Use this skill to configure repository secrets in GitHub repositories (e.g. database credentials, API keys) via the `gh` CLI.

## Workflow

1. **Target Repository**:
   - Ask for or confirm the repository full name: `<owner>/<repo>` (e.g. `polytech-bgf/polytech-bgf-client`).

2. **Secret Keys & Values**:
   - Ask the user which secret names/keys are required.
   - Prompts for values securely.
   - **SECURITY RULE**: Never output or print secret values in logs, responses, or terminal output. Always log secret values as `[REDACTED]`.

3. **Execution**:
   Run helper script:
   ```bash
   .agents/skills/manage-github-secrets/scripts/set-repo-secrets.sh <owner/repo> <SECRET_KEY> <SECRET_VALUE>
   ```

   *Example:*
   ```bash
   .agents/skills/manage-github-secrets/scripts/set-repo-secrets.sh polytech-bgf/polytech-bgf-backend MONGODB_URI "mongodb://..."
   ```
