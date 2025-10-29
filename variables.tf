variable "region" {
  description = "COS bucket deployment region"
  type        = string
  default     = "us-south"
}

variable "broker_url" {
  description = "Cloudflare Worker broker endpoint"
  type        = string
  default     = "https://vibe-manifest-broker.brendanandrewfitzpatrick.workers.dev/sign"
}

variable "tags" {
  description = "Tags for associated cloud resources"
  type        = list(string)
  default     = ["vibe", "vibe-ide-da"]
}
