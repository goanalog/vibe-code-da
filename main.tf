# IBM Cloud provider must authenticate via the environment (Projects/Schematics)
provider "ibm" {}

# Randomized, DNS-safe bucket suffix to guarantee uniqueness for Catalog users
resource "random_string" "bucket_suffix" {
  length  = 8
  upper   = false
  special = false
}

locals {
  bucket_name = "vibe-bucket-${random_string.bucket_suffix.result}"
}

# Cloud Object Storage (Lite) instance for hosting the static site
resource "ibm_resource_instance" "cos" {
  name              = "vibe-cos-${random_string.bucket_suffix.result}"
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = "global"
  resource_group_id = data.ibm_resource_group.default.id
}

# Use default resource group (typical for Projects/Catalog flows)
data "ibm_resource_group" "default" {
  is_default = true
}

# Create the bucket in the chosen region
resource "ibm_cos_bucket" "vibe" {
  bucket_name         = local.bucket_name
  service_instance_id = ibm_resource_instance.cos.guid
  region_location     = var.region
  storage_class       = "standard"
}

# Enable static website hosting
resource "ibm_cos_bucket_website" "website" {
  bucket          = ibm_cos_bucket.vibe.bucket_name
  index_document  = "index.html"
  error_document  = "404.html"
}

# NOTE on public access:
# IBM Cloud Console's "Public Access → Object Reader" is a GUI helper that sets a public reader policy.
# The statement below models that intent so anonymous users can GET bucket objects.
# Depending on provider version/permissions, some environments may need to toggle this in the Console.
resource "ibm_iam_authorization_policy" "public_bucket_reader" {
  roles = ["Reader"]

  resources = [{
    service       = "cloud-object-storage"
    resource_type = "bucket"
    resource      = ibm_cos_bucket.vibe.bucket_name
  }]

  # Public Access Group is a special built-in group that represents anonymous users for COS object reads.
  subjects = [{
    type       = "AccessGroup"
    identifier = "Public Access Group"
  }]
}

# Upload initial site assets
resource "ibm_cos_bucket_object" "index" {
  bucket       = ibm_cos_bucket.vibe.bucket_name
  key          = "index.html"
  content      = var.initial_html
  content_type = "text/html"
  depends_on   = [ibm_cos_bucket_website.website]
}

resource "ibm_cos_bucket_object" "error" {
  bucket       = ibm_cos_bucket.vibe.bucket_name
  key          = "404.html"
  content      = <<EOT
<!DOCTYPE html><html><head><meta charset="utf-8"><title>Not Found</title></head>
<body style="font-family: IBM Plex Sans, sans-serif; background:#000; color:#e5e7eb; text-align:center; padding-top:20vh;">
  <h1 style="font-size:3rem;">404</h1>
  <p>This vibe isn’t manifest yet.</p>
</body></html>
EOT
  content_type = "text/html"
  depends_on   = [ibm_cos_bucket_website.website]
}

# Optional environment context for the front-end (safe to be empty)
resource "ibm_cos_bucket_object" "env_js" {
  bucket       = ibm_cos_bucket.vibe.bucket_name
  key          = "env.js"
  content      = templatefile("${path.module}/env.js.tftpl", {
    project_id = var.project_id
    config_id  = var.config_id
  })
  content_type = "application/javascript"
  depends_on   = [ibm_cos_bucket_website.website]
}
