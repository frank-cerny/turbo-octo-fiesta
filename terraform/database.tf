# Reference: https://oracle-base.com/articles/misc/terraform-oci-autonomous-database
resource "oci_database_autonomous_database" "tf_bsa_adb_prod" {
  compartment_id           = var.root_compartment_id
  cpu_core_count           = 1
  data_storage_size_in_gb  = 20
  data_storage_size_in_tbs = 1
  db_name                  = "bsaapex_prod"
  admin_password           = var.adb_admin_password
  db_version               = "21c"
  db_workload              = "OLTP"
  display_name             = "BSA_AEPX"
  is_free_tier             = true
  license_model            = "LICENSE_INCLUDED"
  # We cannot put the ADB in a subnet or NSG unless it is assigned a private endpoint (which is not free)
  # Terraform will throw an error otherwise
  #   subnet_id = oci_core_subnet.private_bsa_subnet.id
  #   nsg_ids = [
  #       oci_core_network_security_group.private_network_security_group.id
  #   ]
}

# Create a second database to be used for unit testing during Jenkins builds
resource "oci_database_autonomous_database" "tf_bsa_adb_dev" {
  compartment_id           = var.root_compartment_id
  cpu_core_count           = 1
  data_storage_size_in_gb  = 20
  data_storage_size_in_tbs = 1
  db_name                  = "bsaapex_dev"
  admin_password           = var.adb_admin_password
  db_version               = "21c"
  db_workload              = "OLTP"
  display_name             = "BSA_AEPX"
  is_free_tier             = true
  license_model            = "LICENSE_INCLUDED"
}