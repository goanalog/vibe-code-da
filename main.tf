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

resource "ibm_cos_bucket" "site" {
  bucket_name          = local.bucket_name
  resource_instance_id = ibm_resource_instance.cos.id
  region_location      = var.bucket_region
  storage_class        = "standard"
  force_delete         = true
}

# Upload IDE UI
resource "ibm_cos_bucket_object" "index" {
  bucket_crn      = ibm_cos_bucket.site.crn
  bucket_location = var.bucket_region
  key             = "index.html"
  content         = file("${path.module}/web/index.html")
  depends_on      = [ibm_cos_bucket.site]
}

# Upload user-facing sample app
resource "ibm_cos_bucket_object" "app" {
  bucket_crn      = ibm_cos_bucket.site.crn
  bucket_location = var.bucket_region
  key             = "app.html"
  content         = file("${path.module}/web/app.html")
  depends_on      = [ibm_cos_bucket.site]
}

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
  bucket_crn      = ibm_cos_bucket.site.crn
  bucket_location = var.bucket_region
  key             = "vibe-config.json"
  content         = local.vibe_config_json
  depends_on      = [ibm_cos_bucket.site]
}

output "vibe_ide_url" {
  value = local.website_url
}

output "live_app_url" {
  value = local.website_app_url
}

output "bucket_console_url" {
  value = local.bucket_console_url
}
