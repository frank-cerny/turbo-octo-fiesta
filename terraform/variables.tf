variable "tenancy_ocid" {
  type = string
  sensitive = true
}

variable "user_ocid" {
  type = string
  sensitive = true
}

variable "private_key_path" {
  type = string
  sensitive = true
}

variable "fingerprint" {
  type = string
  sensitive = true
}

variable "region" {
  type = string
  sensitive = true
}

variable "root_compartment_id" {
  type = string
  sensitive = true
}

variable "private_key_password" {
    type = string
    sensitive = true
}

variable "utility_image_source_id" {
  type = string
  default = "ocid1.image.oc1.iad.aaaaaaaajpsx7e3rlozmcgczok5u2wpgsxsikzpbachb42h26ztp3i3d7o7a"
}

variable "bastion_public_key" {
  type = string
}