# Used to connect to private compute resources via SSH
resource "oci_bastion_bastion" "main_bastion" {
    bastion_type = "STANDARD"
    compartment_id = var.root_compartment_id
    target_subnet_id = oci_core_subnet.public_bsa_subnet.id
    client_cidr_block_allow_list = [
        "184.184.132.24/32"
    ]
    name = "main-bastion"
    # TODO - Add these later :)
    # defined_tags = {
    #     "Oracle-Tags.CreatedBy" = "oracleidentitycloudservice/terraformuser"
    #     "Oracle-Tags.CreatedOn" = "2022-03-27T18:05:38.250Z"
    # }
}

data "oci_bastion_bastions" "bastions" {
  compartment_id = var.root_compartment_id
  bastion_id              = oci_bastion_bastion.main_bastion.id
}

# TODO (What the heck does this do?)
data "oci_core_services" "bastion_services" {
}