###############################################################################
# Variables (v1.3.3)
###############################################################################

variable "region" {
  description = "IBM Cloud region to deploy resources in"
  type        = string
  default     = "us-south"
}

variable "manifest_broker_url" {
  description = "Cloudflare Worker endpoint for manifest publishing"
  type        = string
  default     = "https://vibe-manifest-broker.brendanandrewfitzpatrick.workers.dev"
}
