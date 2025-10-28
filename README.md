# Vibe IDE — Deployable Architecture (v1.0.0)

**One-click, zero-input** Deployable Architecture for IBM Cloud Catalog & Projects.

- Provisions IBM Cloud Object Storage (Lite)
- Creates a globally unique bucket and enables website hosting
- Uploads three files automatically:
  - `index.html` — from `var.initial_html` (your provided Vibe default)
  - `404.html` — friendly fallback
  - `env.js` — optional project/config context for the front-end
- Emits a single output: `site_url` (public URL)

> Public access is granted so anonymous users can view your site immediately.

## Inputs

- `region` (default: `us-south`)
- `initial_html` (default provided; override if desired)
- `project_id`, `config_id` (optional; used by front-end for deep links)

## Output

- `site_url` — public website endpoint (`https://<bucket>.<region>.cloud-object-storage.appdomain.cloud`)
