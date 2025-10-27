terraform {
  required_version = ">= 1.0.0"

  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.84.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}

provider "ibm" {}

# -------------------------------------------------------------------
# Resource Group Detection: Schematics may inject var.resource_group_id.
# If not provided, fallback to the "Default" resource group by name.
# -------------------------------------------------------------------
data "ibm_resource_group" "fallback" {
  name = "Default"
}

locals {
  resolved_rg = var.resource_group_id != "" ? var.resource_group_id : data.ibm_resource_group.fallback.id
}

# Random suffix for global bucket naming uniqueness
resource "random_id" "suffix" {
  byte_length = 3
}

# -------------------------------------------------------------------
# COS Instance (Lite plan, global region)
# -------------------------------------------------------------------
resource "ibm_resource_instance" "cos" {
  name     = "vibe-cos-${random_id.suffix.hex}"
  service  = "cloud-object-storage"
  plan     = var.cos_plan
  location = "global"
  resource_group_id = local.resolved_rg
}

# -------------------------------------------------------------------
# COS Bucket
# Valid bucket regions include: us-south/us-east/eu-gb/eu-de/ap-...
# Lite instance supports *regional* buckets
# -------------------------------------------------------------------
resource "ibm_cos_bucket" "vibe_bucket" {
  bucket_name          = "vibe-bucket-${random_id.suffix.hex}"
  resource_instance_id = ibm_resource_instance.cos.id
  region_location      = var.bucket_region
  storage_class        = "standard"

  # Enable static website
  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

# -------------------------------------------------------------------
# Upload Web Files (index + app + config)
# key attribute is REQUIRED for v1.84.x provider
# -------------------------------------------------------------------

resource "ibm_cos_bucket_object" "index" {
  bucket             = ibm_cos_bucket.vibe_bucket.bucket_name
  key                = "index.html"
  content            = file("${path.module}/web/index.html")
  content_type       = "text/html"
}

resource "ibm_cos_bucket_object" "app" {
  bucket             = ibm_cos_bucket.vibe_bucket.bucket_name
  key                = "app.html"
  content            = file("${path.module}/web/app.html")
  content_type       = "text/html"
}

resource "ibm_cos_bucket_object" "config" {
  bucket             = ibm_cos_bucket.vibe_bucket.bucket_name
  key                = "vibe-config.json"
  content            = file("${path.module}/web/vibe-config.json")
  content_type       = "application/json"
}

# -------------------------------------------------------------------
# Outputs
# -------------------------------------------------------------------

output "bucket_name" {
  value = ibm_cos_bucket.vibe_bucket.bucket_name
}

output "static_website_url" {
  value = "https://${ibm_cos_bucket.vibe_bucket.bucket_name}.s3.${var.bucket_region}.cloud-object-storage.appdomain.cloud"
}

output "cos_instance_name" {
  value = ibm_resource_instance.cos.name
}
