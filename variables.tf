variable "region" {
  type        = string
  description = "Region for regional resources (e.g., us-south)."
  default     = "us-south"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group to deploy into."
  default     = "Default"
}

variable "prefix" {
  type        = string
  description = "Prefix for resource names. A random suffix will be added for uniqueness."
  default     = "idlake"
}

variable "code_engine_project_name" {
  type        = string
  description = "Code Engine project name."
  default     = "idlake-ce"
}

variable "helper_app_name" {
  type        = string
  description = "Code Engine app name."
  default     = "idlake-helper"
}

variable "icr_namespace" {
  type        = string
  description = "IBM Cloud Container Registry (ICR) namespace (will be created if missing)."
  default     = "idlake"
}

variable "image_tag" {
  type        = string
  description = "Tag applied to the built helper image."
  default     = "1.0.0"
}

variable "ibmcloud_api_key" {
  type        = string
  description = "IBM Cloud API key with permission to write to ICR and manage resources in the target Resource Group."
  sensitive   = true
  default     = null
}