output "site_url" {
  value       = "https://${ibm_cos_bucket.vibe.bucket_name}.${var.region}.cloud-object-storage.appdomain.cloud"
  description = "Public website URL for the deployed Vibe IDE app"
}
