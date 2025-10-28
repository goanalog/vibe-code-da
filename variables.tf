variable "resource_group_id" {
  description = "Resource Group ID (Schematics/Projects will inject this automatically). If blank, falls back to the 'Default' resource group."
  type        = string
  default     = ""
  nullable    = false
}

variable "bucket_region" {
  description = "Region for the bucket (e.g., us-south, us-east, eu-de, eu-gb, etc.)"
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
    error_message = "Only lite or standard are allowed."
  }
}
