# References:
# How to setup an OCI provider: https://oracle-base.com/articles/misc/terraform-oci-provider
# OCI Provider docs: https://registry.terraform.io/providers/oracle/oci/latest/docs

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "4.69.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  private_key_path = var.private_key_path
  private_key_password = var.private_key_password
  fingerprint      = var.fingerprint
  region           = var.region
}