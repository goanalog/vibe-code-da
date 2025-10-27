
# Vibe IDE — Live Static Site (IBM Cloud)

This Deployable Architecture provisions:
- **IBM Cloud Object Storage (Lite)** instance
- A **regional bucket** with **Static Website** hosting enabled
- Publishes `index.html` using either your **Catalog-form input** or the **bundled sample**

## How it works
1. Terraform creates a COS instance (plan: **lite**) and a regional bucket.
2. Website hosting is enabled with `index.html` as the index & error doc.
3. The initial page is uploaded via Terraform:
   - If you provided **Initial HTML** in the Customize step, it's published.
   - Otherwise, we publish the bundled sample in `./static-site/index.html`.

## Public access
IBM COS static websites require **public read** on the bucket. In many accounts this is applied via:
- **Public Access Group → Object Reader** policy on the bucket.
- This sometimes must be set in the IBM Cloud Console.
- If your organization allows it via IAM, apply an equivalent policy with Terraform/IAM.

Until public-read is granted, your website endpoint may return `AccessDenied`.

## Outputs
- **primary_output** — the public website URL (use this to open the app)

## Inputs
- **cos_plan**: defaults to `lite` (per your 1A selection)
- **initial_html**: optional string; leave empty to use the bundled sample

## Notes
- This package is validated for Terraform 1.12 in IBM Cloud Projects/Catalog environments.
- Names are auto-suffixed for global uniqueness.

