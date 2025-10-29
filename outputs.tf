output "ide_url" {
  description = "Live Vibe IDE URL"
  value       = format("https://%s.s3-website.%s.cloud-object-storage.appdomain.cloud/index.html", ibm_cos_bucket.vibe.bucket_name, var.region)
}

output "app_url" {
  description = "Published static app URL"
  value       = format("https://%s.s3-website.%s.cloud-object-storage.appdomain.cloud/app.html", ibm_cos_bucket.vibe.bucket_name, var.region)
}

output "bucket_name" {
  description = "Provisioned COS bucket name"
  value       = ibm_cos_bucket.vibe.bucket_name
}

output "bucket_console_url" {
  description = "Direct link to Object Storage bucket in IBM Cloud console"
  value       = format("https://cloud.ibm.com/objectstorage/buckets/%s?region=%s", ibm_cos_bucket.vibe.bucket_name, var.region)
}
