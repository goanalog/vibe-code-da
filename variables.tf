variable "resource_group_id" {
  description = "Resource Group ID provided by IBM Cloud"
  type        = string
}

variable "bucket_region" {
  description = "Region where the bucket will be created"
  type        = string
  default     = "us-south"
}

variable "cos_plan" {
  description = "COS service plan"
  type        = string
  default     = "lite"
}
