---
name: Setup CD Workflow
description: Generates a fully generic GitHub Actions CD workflow (.github/workflows/cd.yml) for deploying backend and frontend applications to hosting platforms (Vercel, Fly.io, Render, Railway, Docker).
---

# Setup CD Workflow Skill

Use this skill to configure GitHub Actions Continuous Deployment (CD) pipelines for deploying projects to various hosting providers.

## 1. Interactive Clarification Workflow (MANDATORY)

Before executing the generation script, you MUST ask the user the following questions to determine the deployment configuration:

1. **Target Component**:
   - Ask: *Are we setting up CD for the Frontend (Client), Backend, or Both?*
2. **Hosting Platform**:
   - Ask: *Which hosting platform do you want to deploy to? (Options: Vercel, Fly.io, Render, Railway, Docker)*
   - *Recommendation:* Mention that Vercel is recommended for Frontend (React/Vite) and Fly.io is recommended for Backend (NestJS/Node).
3. **Secrets Setup**:
   - Inform the user about the required secrets for their chosen platform:
     - **Vercel**: `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`
     - **Fly.io**: `FLY_API_TOKEN`
     - **Render**: `RENDER_DEPLOY_HOOK_URL`
     - **Railway**: `RAILWAY_TOKEN`
     - **Docker**: `GITHUB_TOKEN` (provided automatically by Actions)
   - Ask: *Do you want me to use the `manage-github-secrets` skill to configure these secrets securely now?*

## 2. Generate the CD Workflow

The CD pipeline is configured to run automatically when code is pushed to the `main` branch.

Run the workflow generation script in the target repository directory, passing the chosen platform:

```bash
.agents/skills/setup-cd-workflow/scripts/generate-cd-workflow.sh <target_dir> <platform>
```

### Supported Platforms (`<platform>`):
- `vercel`
- `fly`
- `render`
- `railway`
- `docker`

*Example (Deploy Backend to Fly.io):*
```bash
.agents/skills/setup-cd-workflow/scripts/generate-cd-workflow.sh ./polytech-bgf-backend fly
```

*Example (Deploy Client to Vercel):*
```bash
.agents/skills/setup-cd-workflow/scripts/generate-cd-workflow.sh ./polytech-bgf-client vercel
```

## 3. Verification & Commit

After generating `.github/workflows/cd.yml`:
1. Commit the workflow file:
   ```bash
   git add .github/workflows/cd.yml
   git commit -m "ci: add generic CD pipeline for <platform>"
   ```
2. Push to GitHub to enable the deployment trigger on the `main` branch.
