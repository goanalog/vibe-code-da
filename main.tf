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
