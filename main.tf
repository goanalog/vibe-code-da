
terraform {
  required_version = ">= 1.5.0"
  required_providers = {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.84.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
  }
}

locals {
  # Suffix for global-unique names; stable per workspace run.
  suffix = lower(replace(random_string.sfx.result, "/[^a-z0-9]/", ""))
  region = var.region
  # Base names
  cos_name    = "vibe-ide-cos-${local.suffix}"
  bucket_name = "vibe-ide-bucket-${local.suffix}"
}

provider "ibm" {
  region = local.region
}

resource "random_string" "sfx" {
  length  = 6
  upper   = false
  numeric = true
  special = false
}

# --------------------------
# Cloud Object Storage (Lite)
# --------------------------
resource "ibm_resource_instance" "cos" {
  name     = local.cos_name
  service  = "cloud-object-storage"
  plan     = var.cos_plan  # "lite" by default
  location = "global"
  tags     = ["vibe", "vibe-ide", "static-site"]
}

# Regional bucket for website hosting
resource "ibm_cos_bucket" "site" {
  bucket_name          = local.bucket_name
  resource_instance_id = ibm_resource_instance.cos.id
  region_location      = var.bucket_region
  storage_class        = var.bucket_storage_class
  force_delete         = true

  # Website hosting requires a website configuration attached below.
  # Public access must be enabled at the account/bucket policy level in console
  # or via IAM policy for the Public Access group (often manual).
  # See README for instructions.
}

# Website configuration
resource "ibm_cos_bucket_website" "site" {
  bucket_crn  = ibm_cos_bucket.site.crn
  index_doc   = "index.html"
  error_doc   = "index.html"
  # Note: website endpoint is available via the output below.
}

# Upload the initial index.html
# If var.initial_html is non-empty, use it; otherwise use the bundled sample file.
locals {
  initial_index_content = trim(var.initial_html) != "" ? var.initial_html : file("${path.module}/static-site/index.html")
}

resource "ibm_cos_bucket_object" "index" {
  resource_instance_id = ibm_resource_instance.cos.id
  bucket_crn           = ibm_cos_bucket.site.crn
  key                  = "index.html"
  content              = local.initial_index_content
  content_type         = "text/html"
  force                = true
}
