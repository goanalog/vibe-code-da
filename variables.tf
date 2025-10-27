variable "resource_group_id" {
  description = "Resource Group ID provided automatically by IBM Cloud Schematics"
  type        = string
  nullable    = false
  default     = ""
}

variable "bucket_region" {
  description = "Region where the bucket will be created"
  type        = string
  default     = "us-south"
  validation {
    condition     = length(var.bucket_region) > 0
    error_message = "bucket_region must not be empty."
  }
}

variable "cos_plan" {
  description = "COS service plan"
  type        = string
  default     = "lite"
  validation {
    condition     = var.cos_plan == "lite" || var.cos_plan == "standard"
    error_message = "Only lite or standard allowed."
  }
}
