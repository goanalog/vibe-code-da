terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.84.3"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}
