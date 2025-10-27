# Vibe IDE — Zero-Config Creative Hosting (COS) v1.0.0

This package deploys:
- IBM Cloud **Object Storage** (global, Lite)
- A unique **bucket** with website hosting
- **Public-read** policy (GET only)
- The **Vibe IDE** (`index.html`) and a **sample app** (`app.html`)
- A small `vibe-config.json` the IDE uses to show deep links

## End-User Flow
1. Open **Vibe IDE** (`vibe_ide_url` output).
2. Editor loads **app.html** into the left pane, Viewer shows it on the right.
3. Edit → **Preview** → **Download app.html**.
4. Click **Open Bucket** → upload to replace `app.html`.
5. Share **live_app_url** (public site). The IDE is never overwritten.

## Outputs
- `vibe_ide_url` — editor landing page
- `live_app_url` — public sample app
- `bucket_console_url` — IBM Cloud console link

## Catalog Safety
- **No HTML in Terraform variables** (avoids `<script>` validation issues).
- COS is **global**, bucket is regional, names are globally unique via random suffix.