variable "region" {
  description = "Target region for IBM Cloud resources"
  type        = string
  default     = "us-south"
}

variable "project_id" {
  type        = string
  default     = ""
}

variable "config_id" {
  type        = string
  default     = ""
}
