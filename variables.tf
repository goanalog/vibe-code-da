variable "resource_group" {
  description = "IBM Cloud Resource Group name"
  type        = string
  default     = "default"
}

variable "region" {
  description = "Control-plane region for IBM provider calls"
  type        = string
  default     = "us-south"
}

variable "bucket_region" {
  description = "Region for the COS bucket (website hosting). Example: us-south"
  type        = string
  default     = "us-south"
}

variable "cos_plan" {
  description = "COS plan for the service instance"
  type        = string
  default     = "lite"
}