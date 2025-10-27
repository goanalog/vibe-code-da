output "helper_app_url" {
  description = "Public URL of the Helper App"
  value       = ibm_code_engine_app.helper_app.endpoint
}

output "cos_bucket_name" {
  description = "COS bucket name"
  value       = ibm_cos_bucket.cos_bucket.bucket_name
}

output "cos_bucket_console_url" {
  description = "Console link to the COS bucket"
  value       = "https://cloud.ibm.com/objectstorage/buckets?bucket=${ibm_cos_bucket.cos_bucket.bucket_name}"
}

output "code_engine_app_console_url" {
  description = "Open the Code Engine app in the IBM Cloud console"
  value       = "https://cloud.ibm.com/codeengine/project/${ibm_code_engine_project.ce.guid}/applications/${ibm_code_engine_app.helper_app.id}"
}

output "primaryoutput" {
  value = {
    "Open Helper App"   = ibm_code_engine_app.helper_app.endpoint
    "Open COS Bucket"   = "https://cloud.ibm.com/objectstorage/buckets?bucket=${ibm_cos_bucket.cos_bucket.bucket_name}"
    "Code Engine (App)" = "https://cloud.ibm.com/codeengine/project/${ibm_code_engine_project.ce.guid}/applications/${ibm_code_engine_app.helper_app.id}"
  }
}
