###############################################################################
# Vibe IDE — Deployable Architecture (v1.3.4)
# Compatible with IBM Provider v1.84.x (Schematics / Catalog)
###############################################################################

###############################################################################
# Vibe IDE — Deployable Architecture (v1.3.4)
###############################################################################

provider "ibm" {}

###############################################################################
# Random suffix for unique bucket names
###############################################################################
resource "random_id" "suffix" {
  byte_length = 3
}

###############################################################################
# COS Objects (upload static assets)
###############################################################################

# Create a unique public bucket for this deployment
resource "random_id" "suffix" {
  byte_length = 3
}

resource "ibm_cos_bucket" "vibe" {
  bucket_name       = "vibe-bucket-${random_id.suffix.hex}"
  resource_instance_id = ibm_resource_instance.cos.guid
  storage_class      = "standard"
  region_location    = var.region
  force_delete       = true

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

Public Access Policy
resource "ibm_cos_bucket_public_access" "public" {
  bucket_crn = ibm_cos_bucket.vibe.crn
  access_type = "public"
}

resource "ibm_cos_bucket_object" "index" {
  bucket_crn    = ibm_cos_bucket.vibe.crn
  bucket_region = ibm_cos_bucket.vibe.region_location
  key           = "index.html"
  file          = "index.html"
}

resource "ibm_cos_bucket_object" "app" {
  bucket_crn    = ibm_cos_bucket.vibe.crn
  bucket_region = ibm_cos_bucket.vibe.region_location
  key           = "app.html"
  file          = "app.html"
}

resource "ibm_cos_bucket_object" "config" {
  bucket_crn    = ibm_cos_bucket.vibe.crn
  bucket_region = ibm_cos_bucket.vibe.region_location
  key           = "vibe-config.json"
  file          = "vibe-config.json"
}

resource "ibm_cos_bucket_object" "error" {
  bucket_crn    = ibm_cos_bucket.vibe.crn
  bucket_region = ibm_cos_bucket.vibe.region_location
  key           = "error.html"
  content       = "<html><body><h1>Error loading Vibe</h1></body></html>"
}
