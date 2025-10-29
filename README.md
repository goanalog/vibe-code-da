# Vibe IDE — Deployable Architecture (v1.1.2, A-1 demo; provider 1.84 compatible)

- COS Lite instance + unique bucket
- Public read via S3 bucket policy in `ibm_cos_bucket_configuration`
- Anonymous PUT permitted only for `app.html` (A-1 demo)
- CORS enabled (GET/PUT/HEAD/OPTIONS)
- Uploaded: `index.html` (IDE), `app.html` (default vibe), `vibe-config.json`, `404.html`
- Output `site_url` launches IDE immediately

> Security note: Anyone with the PUT URL could overwrite `app.html`. Prefer a signed-URL broker (Code Engine) for production.
