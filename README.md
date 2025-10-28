# Vibe IDE — Deployable Architecture (v1.1.0, A‑1 demo)

**One‑click, zero‑input** DA that deploys the **full Vibe IDE** into IBM Cloud Object Storage.

- Public read enabled (website endpoint)
- Anonymous PUT enabled **only for `app.html`** (demo publish model)
- CORS allows GET/HEAD/PUT for front-end actions
- Files uploaded:
  - `index.html` — IDE UI (edit + preview + manifest)
  - `app.html` — Default vibe sample (editable target)
  - `vibe-config.json` — runtime endpoints for IDE
  - `404.html` — fallback

**Outputs**
- `site_url` — opens IDE (index.html)
- `s3_put_url` — direct PUT endpoint the IDE uses for `app.html`

> NOTE: A‑1 is a demo model that prioritizes Wow-factor. Anyone who discovers the PUT URL could overwrite `app.html`. Use A‑2 (signed URL broker) for production.
