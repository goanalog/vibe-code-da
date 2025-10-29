###############################################################################
# Vibe IDE — Outputs (v1.3.2)
# Centralized outputs for IBM Cloud Catalog and Projects
###############################################################################

output "ide_url" {
  description = "Public URL to open the deployed Vibe IDE (index.html)"
  value       = "https://${ibm_cos_bucket_public_access.vibe.endpoint}/${ibm_cos_bucket_public_access.vibe.bucket}/index.html"
}

output "app_url" {
  description = "Public URL to open the user’s published Vibe app (app.html)"
  value       = "https://${ibm_cos_bucket_public_access.vibe.endpoint}/${ibm_cos_bucket_public_access.vibe.bucket}/app.html"
}

output "bucket_name" {
  description = "COS bucket name created for this Vibe IDE deployment"
  value       = ibm_cos_bucket_public_access.vibe.bucket
}

output "bucket_console_url" {
  description = "IBM Cloud Console URL to manage this bucket"
  value       = "https://cloud.ibm.com/objectstorage/buckets/${ibm_cos_bucket_public_access.vibe.bucket}?region=${var.region}"
}

###############################################################################
# Optional debugging and convenience outputs
###############################################################################

output "deployment_region" {
  description = "IBM Cloud region used for this deployment"
  value       = var.region
}

output "manifest_broker_url" {
  description = "The Cloudflare Worker endpoint used for manifest publishing"
  value       = var.manifest_broker_url
}
