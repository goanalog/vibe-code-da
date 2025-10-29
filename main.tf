###############################################################################
# Vibe IDE — Deployable Architecture (v1.3.3)
###############################################################################

provider "ibm" {}

###############################################################################
# Random suffix for unique bucket names
###############################################################################
resource "random_id" "suffix" {
  byte_length = 3
}

###############################################################################
# COS Bucket and Public Access
###############################################################################
resource "ibm_cos_bucket" "vibe" {
  bucket_name   = "vibe-bucket-${random_id.suffix.hex}"
  region        = var.region
  storage_class = "standard"
}

resource "ibm_cos_bucket_website" "vibe" {
  bucket          = ibm_cos_bucket.vibe.bucket_name
  mainpage_suffix = "index.html"
  error_key       = "error.html"
}

resource "ibm_cos_bucket_public_access" "vibe" {
  bucket = ibm_cos_bucket.vibe.bucket_name

  public_access {
    object = true
  }
}

###############################################################################
# Upload static app files
###############################################################################
resource "ibm_cos_bucket_object" "index" {
  bucket        = ibm_cos_bucket.vibe.bucket_name
  key           = "index.html"
  source        = "index.html"
}

resource "ibm_cos_bucket_object" "app" {
  bucket        = ibm_cos_bucket.vibe.bucket_name
  key           = "app.html"
  source        = "app.html"
}

resource "ibm_cos_bucket_object" "vibe_config" {
  bucket        = ibm_cos_bucket.vibe.bucket_name
  key           = "vibe-config.json"
  source        = "vibe-config.json"
}

resource "ibm_cos_bucket_object" "error" {
  bucket        = ibm_cos_bucket.vibe.bucket_name
  key           = "error.html"
  content       = "<html><body><h1>Error loading Vibe</h1></body></html>"
}

###############################################################################
# Outputs handled separately in outputs.tf
###############################################################################
