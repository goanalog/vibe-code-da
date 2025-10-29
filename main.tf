###############################################################################
# Vibe IDE — Deployable Architecture (v1.3.4)
# Compatible with IBM Provider v1.84.x (Schematics / Catalog)
###############################################################################

###############################################################################
# Vibe IDE — Deployable Architecture (v1.3.4)
###############################################################################

provider "ibm" {}

resource "random_id" "suffix" {
  byte_length = 3
}


###############################################################################
# Random suffix for unique bucket names
###############################################################################
resource "random_id" "suffix" {
  byte_length = 3
}

###############################################################################
# COS Service Instance + Bucket
###############################################################################
resource "ibm_resource_instance" "cos" {
  name     = "vibe-cos-${random_id.suffix.hex}"
  service  = "cloud-object-storage"
  plan     = "lite"
  location = "global"
}

resource "ibm_cos_bucket" "vibe" {
  bucket_name          = "vibe-bucket-${random_id.suffix.hex}"
  resource_instance_id = ibm_resource_instance.cos.id
  storage_class        = "standard"
  force_delete         = true
}

###############################################################################
# Upload static app files to the bucket
###############################################################################
resource "ibm_cos_bucket_object" "index" {
  bucket_crn      = ibm_cos_bucket.vibe.crn
  bucket_location = ibm_cos_bucket.vibe.location
  key             = "index.html"
  file            = "index.html"
}

resource "ibm_cos_bucket_object" "app" {
  bucket_crn      = ibm_cos_bucket.vibe.crn
  bucket_location = ibm_cos_bucket.vibe.location
  key             = "app.html"
  file            = "app.html"
}

resource "ibm_cos_bucket_object" "config" {
  bucket_crn      = ibm_cos_bucket.vibe.crn
  bucket_location = ibm_cos_bucket.vibe.location
  key             = "vibe-config.json"
  file            = "vibe-config.json"
}

resource "ibm_cos_bucket_object" "error" {
  bucket_crn      = ibm_cos_bucket.vibe.crn
  bucket_location = ibm_cos_bucket.vibe.location
  key             = "error.html"
  content         = "<html><body><h1>Error loading Vibe</h1></body></html>"
}
