terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      # Require a newer provider version known to support ibm_cos_bucket_public_access
      version = "~> 1.57"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}
