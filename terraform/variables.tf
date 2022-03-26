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