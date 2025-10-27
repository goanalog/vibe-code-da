
# Primary output: Public website URL
# Note: You must grant Public Object Reader on this bucket for anonymous access.
output "primary_output" {
  description = "Public Website URL for Vibe IDE"
  value       = ibm_cos_bucket_website.site.website_url
}

output "bucket_name" {
  value       = ibm_cos_bucket.site.bucket_name
  description = "Deployed COS bucket name"
}

output "cos_instance_name" {
  value       = ibm_resource_instance.cos.name
  description = "COS instance name"
}
