data "ibm_resource_group" "rg" {
  name = var.resource_group
}

resource "random_id" "suffix" {
  byte_length = 3
}

resource "ibm_resource_instance" "cos" {
  name              = "vibe-cos-${random_id.suffix.hex}"
  service           = "cloud-object-storage"
  plan              = var.cos_plan
  location          = "global"
  resource_group_id = data.ibm_resource_group.rg.id
}

locals {
  bucket_name = "vibe-site-${random_id.suffix.hex}"
}

# Bucket for static hosting (no website{} block - provider no longer supports it)
resource "ibm_cos_bucket" "site" {
  bucket_name          = local.bucket_name
  resource_instance_id = ibm_resource_instance.cos.id
  region_location      = var.bucket_region
  storage_class        = "standard"
  force_delete         = true
}

# Public Access Group lookup
data "ibm_iam_access_group" "public" {
  name = "Public Access Group"
}

# IAM policy: Public Group -> Object Reader on this bucket
resource "ibm_iam_policy" "public_reader" {
  roles = ["Object Reader"]

  resources {
    attributes {
      name  = "resource"
      value = "bucket"
    }
    attributes {
      name  = "resourceName"
      value = local.bucket_name
    }
  }

  subjects {
    attributes {
      name  = "iam_id"
      value = data.ibm_iam_access_group.public.id
    }
  }

  depends_on = [ibm_resource_instance.cos]
}

# Upload IDE and sample app
resource "ibm_cos_bucket_object" "index" {
  bucket_crn    = ibm_cos_bucket.site.crn
  bucket_region = var.bucket_region
  key           = "index.html"
  content_type  = "text/html"
  content       = file("${path.module}/../web/index.html")
  force_destroy = true
  depends_on    = [ibm_iam_policy.public_reader]
}

resource "ibm_cos_bucket_object" "app" {
  bucket_crn    = ibm_cos_bucket.site.crn
  bucket_region = var.bucket_region
  key           = "app.html"
  content_type  = "text/html"
  content       = file("${path.module}/../web/app.html")
  force_destroy = true
  depends_on    = [ibm_iam_policy.public_reader]
}

# Upload config JSON with deep links for UI
locals {
  website_url        = "https://${ibm_cos_bucket.site.bucket_name}.s3-web.${var.bucket_region}.cloud-object-storage.appdomain.cloud/index.html"
  website_app_url    = "https://${ibm_cos_bucket.site.bucket_name}.s3-web.${var.bucket_region}.cloud-object-storage.appdomain.cloud/app.html"
  bucket_console_url = "https://cloud.ibm.com/objectstorage/buckets?bucket=${ibm_cos_bucket.site.bucket_name}&region=${var.bucket_region}"

  vibe_config_json = jsonencode({
    website_url        = local.website_app_url
    bucket_console_url = local.bucket_console_url
  })
}

resource "ibm_cos_bucket_object" "config" {
  bucket_crn    = ibm_cos_bucket.site.crn
  bucket_region = var.bucket_region
  key           = "vibe-config.json"
  content_type  = "application/json"
  content       = local.vibe_config_json
  force_destroy = true
  depends_on    = [ibm_iam_policy.public_reader]
}

# Outputs
output "vibe_ide_url" {
  description = "Open the Vibe IDE UI"
  value       = local.website_url
}

output "live_app_url" {
  description = "Public URL to the live sample app (app.html)"
  value       = local.website_app_url
}

output "bucket_console_url" {
  description = "Open the bucket in IBM Cloud console"
  value       = local.bucket_console_url
}
