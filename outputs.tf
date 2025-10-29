output "ide_url" {
  description = "Public URL to open the deployed Vibe IDE (index.html)"
  value       = "https://s3.${ibm_cos_bucket.vibe.location}.cloud-object-storage.appdomain.cloud/${ibm_cos_bucket.vibe.bucket_name}/index.html"
}

output "app_url" {
  description = "Public URL to open the user’s published Vibe app (app.html)"
  value       = "https://s3.${ibm_cos_bucket.vibe.location}.cloud-object-storage.appdomain.cloud/${ibm_cos_bucket.vibe.bucket_name}/app.html"
}

output "bucket_name" {
  description = "COS bucket name created for this Vibe IDE deployment"
  value       = ibm_cos_bucket.vibe.bucket_name
}

output "bucket_console_url" {
  description = "IBM Cloud Console URL to manage this bucket"
  value       = "https://cloud.ibm.com/objectstorage/buckets/${ibm_cos_bucket.vibe.bucket_name}?region=${ibm_cos_bucket.vibe.location}"
}

output "manifest_broker_url" {
  description = "The Cloudflare Worker endpoint used for manifest publishing"
  value       = var.manifest_broker_url
}
