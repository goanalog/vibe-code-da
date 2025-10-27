variable "resource_group" {
  description = "Where your vibe lives organizationally. If unsure, 'default' is fine."
  type        = string
  default     = "default"
}

variable "region" {
  description = "IBM Cloud region for your Object Storage bucket. 'us-south' is a steady classic."
  type        = string
  default     = "us-south"
}

variable "cos_instance_name" {
  description = "Optional: name for your IBM Cloud Object Storage instance. Leave blank to auto-generate."
  type        = string
  default     = ""
}

variable "bucket_name" {
  description = "Optional: bucket name (lowercase, no spaces). Leave blank to auto-generate."
  type        = string
  default     = ""
}

variable "index_html" {
  description = "Paste your full HTML here — it becomes your app’s index.html when deployed. Leave blank to use the sample app."
  type        = string
  default     = ""
}