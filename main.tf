provider "ibm" {}

# Resolve resource group:
# - Use injected var.resource_group_id when present
# - Otherwise, fall back to the account's "Default" resource group by name
data "ibm_resource_group" "fallback" {
  name = "Default"
}

locals {
  resolved_rg = var.resource_group_id != "" ? var.resource_group_id : data.ibm_resource_group.fallback.id
}

# Short random suffix for uniqueness (global bucket namespace)
resource "random_id" "suffix" {
  byte_length = 3
}

# COS instance (global)
resource "ibm_resource_instance" "cos" {
  name              = "vibe-cos-${random_id.suffix.hex}"
  service           = "cloud-object-storage"
  plan              = var.cos_plan
  location          = "global"
  resource_group_id = local.resolved_rg
}

# Bucket (regional)
resource "ibm_cos_bucket" "vibe_bucket" {
  bucket_name          = "vibe-bucket-${random_id.suffix.hex}"
  resource_instance_id = ibm_resource_instance.cos.id
  region_location      = var.bucket_region
  storage_class        = "standard"
  # public_access and website block removed, as they are not supported
  # and will be replaced by an IAM policy.
}

# Data source block for "public_access_group" removed as it's not supported by this provider version.
# We will use the static ID "AccessGroupId-PublicAccess" instead.

# Grant "Object Reader" role to the "Public Access" group for our new bucket
# This is the "IBM way" of enabling public access for a static website
resource "ibm_iam_access_group_policy" "bucket_public_reader" {
  # Use the well-known static ID for the Public Access group
  access_group_id = "AccessGroupId-PublicAccess"
  roles           = ["Object Reader"]

  resources {
    service              = "cloud-object-storage"
    resource_instance_id = ibm_resource_instance.cos.id
    resource_type        = "bucket"
    resource             = ibm_cos_bucket.vibe_bucket.bucket_name
  }
}

# Upload IDE (index), sample app (app), and config (JSON)
# Use the CRN + bucket_location form (works across provider variants)
resource "ibm_cos_bucket_object" "index" {
  bucket_crn    = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.bucket_region
  key           = "index.html"
  acl           = "public-read" # Set object ACL to public
  # Reverted from 'source' to 'content' for compatibility with older provider
  content = file("${path.module}/web/index.html")
  # content_type removed - provider will auto-detect
}

resource "ibm_cos_bucket_object" "app" {
  bucket_crn    = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.bucket_region
  key           = "app.html"
  acl           = "public-read" # Set object ACL to public
  # Reverted from 'source' to 'content' for compatibility with older provider
  content = file("${path.module}/web/app.html")
  # content_type removed - provider will auto-detect
}

# Minimal config JSON the IDE can fetch for links/back-refs
locals {
  bucket_name        = ibm_cos_bucket.vibe_bucket.bucket_name
  # You asked for the "website" endpoint style:
  website_base       = "https://${local.bucket_name}.website.${var.bucket_region}.cloud-object-storage.appdomain.cloud"
  website_index_url  = "${local.website_base}/index.html"
  website_app_url    = "${local.website_base}/app.html"
  bucket_console_url = "https://cloud.ibm.com/objectstorage/buckets?bucket=${local.bucket_name}&region=${var.bucket_region}"

  vibe_config_json = jsonencode({
    bucket_console_url = local.bucket_console_url
    website_url        = local.website_app_url
  })
}

resource "ibm_cos_bucket_object" "config" {
  bucket_crn    = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.bucket_region
  key           = "vibe-config.json"
  acl           = "public-read" # Set object ACL to public
  content       = local.vibe_config_json # Keep content here as it's generated
  # content_type removed - provider will auto-detect
}

# Outputs
output "bucket_name" {
  value = local.bucket_name
}

output "vibe_ide_url" {
  description = "Vibe IDE (index.html) via website endpoint"
  value       = local.website_index_url
}

output "live_app_url" {
  description = "Sample app (app.html) via website endpoint"
  value       = local.website_app_url
}

output "bucket_console_url" {
  value = local.bucket_console_url
}

