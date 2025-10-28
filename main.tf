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
  # and will be replaced by a dedicated resource.
}

# REMOVED: ibm_cos_bucket_public_access (not supported by this provider)
# resource "ibm_cos_bucket_public_access" "public_access" { ... }

# ADDED BACK: The IAM policy, which we know can be created.
resource "ibm_iam_access_group_policy" "bucket_public_reader" {
  # Use the well-known static ID for the Public Access group
  access_group_id = "AccessGroupId-PublicAccess"

  # FIX: Set roles to just Content Reader (based on user screenshot and working manual policy)
  roles = ["Content Reader"]

  resources {
    service = "cloud-object-storage"
    # TROUBLESHOOTING: Remove resource_instance_id, target bucket by name only.
    # resource_instance_id = ibm_resource_instance.cos.id
    # Scoping policy to the specific bucket
    resource_type = "bucket"
    resource      = ibm_cos_bucket.vibe_bucket.bucket_name
  }
}


# Upload IDE (index), sample app (app), and config (JSON)
# Use the CRN + bucket_location form (works across provider variants)
resource "ibm_cos_bucket_object" "index" {
  bucket_crn    = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.bucket_region
  key           = "index.html"
  # acl = "public-read" # Removed: Not supported by this provider version
  # Reverted from 'source' to 'content' for compatibility with older provider
  content = file("${path.module}/web/index.html")
  # content_type removed - provider will auto-detect
}

resource "ibm_cos_bucket_object" "app" {
  bucket_crn    = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.bucket_region
  key           = "app.html"
  # acl = "public-read" # Removed: Not supported by this provider version
  # Reverted from 'source' to 'content' for compatibility with older provider
  content = file("${path.module}/web/app.html")
  # content_type removed - provider will auto-detect
}

# Minimal config JSON the IDE can fetch for links/back-refs
locals {
  bucket_name = ibm_cos_bucket.vibe_bucket.bucket_name

  # Keep the standard S3 endpoint format.
  s3_standard_base = "https://s3.${var.bucket_region}.cloud-object-storage.appdomain.cloud/${local.bucket_name}"
  s3_index_url     = "${local.s3_standard_base}/index.html"
  s3_app_url       = "${local.s3_standard_base}/app.html"

  # FIX: Update console URL to use the URL-encoded COS instance CRN.
  bucket_console_url = "https://cloud.ibm.com/objectstorage/${urlencode(ibm_resource_instance.cos.crn)}"

  vibe_config_json = jsonencode({
    bucket_console_url = local.bucket_console_url
    website_url        = local.s3_app_url # Point config to the standard S3 URL
  })
}

resource "ibm_cos_bucket_object" "config" {
  bucket_crn    = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.bucket_region
  key           = "vibe-config.json"
  # acl = "public-read" # Removed: Not supported by this provider version
  content       = local.vibe_config_json # Keep content here as it's generated
  # content_type removed - provider will auto-detect
}

# Outputs
output "bucket_name" {
  value = local.bucket_name
}

output "vibe_ide_url" {
  description = "Vibe IDE (index.html) via standard S3 endpoint"
  value       = local.s3_index_url # Updated to standard S3 URL
}

output "live_app_url" {
  description = "Sample app (app.html) via standard S3 endpoint"
  value       = local.s3_app_url # Updated to standard S3 URL
}

output "bucket_console_url" {
  description = "Link to the COS instance in IBM Cloud console" # Updated description
  value       = local.bucket_console_url                      # Updated to new format
}

