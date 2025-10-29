
# Vibe IDE — Zero-Input Manifest (v1.3.1)

Per-deployment COS bucket. IDE publishes via Cloudflare Worker using pre-signed PUT for `app.html`. Browser never sees credentials. Zero inputs; Catalog-clean.

## Deploy
- Import this DA into your Private Catalog or create a Schematics workspace from it.
- Apply. Outputs include `ide_url` and `app_url`.

## Worker (once)
- Deploy `broker/` Worker and set secrets: `COS_ACCESS_KEY_ID`, `COS_SECRET_ACCESS_KEY`, `COS_REGION` (e.g., us-south).
- Endpoint: `/sign`. Request body: `{ "bucket": "<vibe-bucket-...>", "key": "app.html" }`.

## End-user
- Open IDE → edit → **Manifest** → share `app_url`.
