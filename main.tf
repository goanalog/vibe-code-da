terraform {
  required_version = ">= 1.5.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.84.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "ibm" {
  region = var.region
}

data "ibm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "ibm_resource_instance" "cos" {
  name              = "${var.prefix}-cos"
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = "global"
  resource_group_id = data.ibm_resource_group.rg.id
  tags              = ["idlake", "da", "base"]
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "ibm_cos_bucket" "cos_bucket" {
  bucket_name          = "${var.prefix}-${random_string.suffix.result}"
  resource_crn         = ibm_resource_instance.cos.id
  single_site_location = var.region
  storage_class        = "standard"
  force_delete         = true
}

resource "ibm_resource_key" "cos_key" {
  name                 = "${var.prefix}-cos-writer"
  role                 = "Writer"
  resource_instance_id = ibm_resource_instance.cos.id
  parameters           = { HMAC = true }
  tags                 = ["idlake", "da", "creds"]
}

locals {
  sample_dir   = "${path.root}/../../sample-data"
  sample_files = fileset(local.sample_dir, "*.csv")
}

resource "ibm_cos_bucket_object" "samples" {
  for_each        = { for f in local.sample_files : f => f }
  bucket_crn      = ibm_cos_bucket.cos_bucket.crn
  bucket_location = var.region

  key          = basename(each.value)
  content      = file("${local.sample_dir}/${each.value}")
  content_type = "text/csv"
}

resource "ibm_code_engine_project" "ce" {
  name              = var.code_engine_project_name
  region            = var.region
  resource_group_id = data.ibm_resource_group.rg.id
  tags              = ["idlake", "da", "base"]
}

locals {
  icr_host_by_region = {
    "us-south" = "us.icr.io"
    "us-east"  = "us.icr.io"
    "eu-de"    = "de.icr.io"
    "eu-gb"    = "uk.icr.io"
    "jp-tok"   = "jp.icr.io"
    "jp-osa"   = "jp.icr.io"
    "ca-tor"   = "ca.icr.io"
    "br-sao"   = "br.icr.io"
  }
  icr_region_code_by_region = {
    "us-south" = "us"
    "us-east"  = "us"
    "eu-de"    = "de"
    "eu-gb"    = "uk"
    "jp-tok"   = "jp"
    "jp-osa"   = "jp"
    "ca-tor"   = "ca"
    "br-sao"   = "br"
  }

  icr_host        = lookup(local.icr_host_by_region, var.region, "us.icr.io")
  icr_region_code = lookup(local.icr_region_code_by_region, var.region, "us")
  image_repo      = "${local.icr_host}/${var.icr_namespace}/${var.helper_app_name}:${var.image_tag}"
}

resource "ibm_cr_namespace" "ns" {
  name   = var.icr_namespace
  region = local.icr_region_code
}

resource "ibm_code_engine_secret" "registry" {
  project_id = ibm_code_engine_project.ce.id
  name       = "registry-secret"
  data = {
    username = "iamapikey"
    password = var.ibmcloud_api_key
    server   = local.icr_host
  }
}

resource "ibm_code_engine_build" "helper_app" {
  project_id  = ibm_code_engine_project.ce.id
  name        = "${var.helper_app_name}-build"
  source      = "local"
  context_dir = "${path.module}/../../helper-app"

  strategy {
    type       = "dockerfile"
    dockerfile = "Dockerfile.txt"
  }

  output_image  = local.image_repo
  output_secret = ibm_code_engine_secret.registry.name

  depends_on = [ibm_code_engine_project.ce, ibm_cr_namespace.ns]
}

resource "ibm_code_engine_configmap" "cfg" {
  project_id = ibm_code_engine_project.ce.id
  name       = "${var.helper_app_name}-cfg"
  data = {
    COS_BUCKET = ibm_cos_bucket.cos_bucket.bucket_name
    REGION     = var.region
  }
}

resource "ibm_code_engine_secret" "cos_secret" {
  project_id = ibm_code_engine_project.ce.id
  name       = "${var.helper_app_name}-cos"
  data = {
    COS_ACCESS_KEY_ID     = try(ibm_resource_key.cos_key.credentials["cos_hmac_keys"]["access_key_id"], "")
    COS_SECRET_ACCESS_KEY = try(ibm_resource_key.cos_key.credentials["cos_hmac_keys"]["secret_access_key"], "")
  }
}

resource "ibm_code_engine_app" "helper_app" {
  project_id      = ibm_code_engine_project.ce.id
  name            = var.helper_app_name
  image_reference = ibm_code_engine_build.helper_app.output_image

  port      = 8080
  cpu       = "0.25"
  memory    = "0.5G"
  min_scale = 0
  max_scale = 2

  run_env_variables = [
    { type = "config_map", name = ibm_code_engine_configmap.cfg.name, key = "COS_BUCKET", value = "COS_BUCKET" },
    { type = "config_map", name = ibm_code_engine_configmap.cfg.name, key = "REGION",     value = "REGION"     },
    { type = "secret",     name = ibm_code_engine_secret.cos_secret.name, key = "COS_ACCESS_KEY_ID",     value = "COS_ACCESS_KEY_ID" },
    { type = "secret",     name = ibm_code_engine_secret.cos_secret.name, key = "COS_SECRET_ACCESS_KEY", value = "COS_SECRET_ACCESS_KEY" }
  ]

  managed_domain_mappings = "local_public"

  depends_on = [
    ibm_code_engine_secret.registry,
    ibm_code_engine_build.helper_app,
    ibm_cos_bucket.cos_bucket,
    ibm_cos_bucket_object.samples
  ]
}
