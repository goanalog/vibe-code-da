output "site_url" {
  value       = "https://${ibm_cos_bucket.vibe.bucket_name}.${var.region}.cloud-object-storage.appdomain.cloud/index.html"
  description = "Public IDE URL (start editing immediately)"
}

output "s3_put_url" {
  value       = "https://s3.${var.region}.cloud-object-storage.appdomain.cloud/${ibm_cos_bucket.vibe.bucket_name}/app.html"
  description = "Anonymous PUT endpoint used by the IDE to publish app.html (A-1 demo)"
}
