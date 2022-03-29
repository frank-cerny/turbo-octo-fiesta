# Reference: https://oracle-base.com/articles/misc/terraform-oci-autonomous-database
resource "oci_database_autonomous_database" "tf_bsa_adb" {
  compartment_id           = var.root_compartment_id
  cpu_core_count           = 1
  data_storage_size_in_gb  = 20
  data_storage_size_in_tbs = 0
  db_name                  = "bsaapex"
  admin_password           = var.adb_admin_password
  db_version               = "21C"
  db_workload              = "DW"
  display_name             = "BSA_AEPX"
  is_free_tier             = true
  license_model            = "LICENSE_INCLUDED"
  subnet_id = oci_core_subnet.private_bsa_subnet.id
  nsg_ids = [
      oci_core_network_security_group.private_network_security_group.id
  ]
}

# Outputs
output "db_name" {
  value = oci_database_autonomous_database.tf_bsa_adb.display_name
}

output "db_state" {
  value = oci_database_autonomous_database.tf_bsa_adb.state
}