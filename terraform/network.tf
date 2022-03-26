# Virtual Cloud Network to house all Apex resources
resource "oci_core_vcn" "main_vcn" {
    #Required
    compartment_id = var.root_compartment_id

    #Optional
    cidr_blocks = [
        "192.168.0.0/16"
    ]
    display_name = "Main Network"
    dns_label = "main"
    freeform_tags = {"Purpose"= "BSA"}
    is_ipv6enabled = false
}

# Create two subnets inside the main network (public and private)
resource "oci_core_subnet" "public_bsa_subnet" {
    #Required
    cidr_block = "192.168.1.0/24"
    compartment_id = var.root_compartment_id
    vcn_id = oci_core_vcn.main_vcn.id
    display_name = "Public BSA Subnet"

    # TBA
    # prohibit_internet_ingress = var.subnet_prohibit_internet_ingress
    # prohibit_public_ip_on_vnic = var.subnet_prohibit_public_ip_on_vnic
    # route_table_id = oci_core_route_table.test_route_table.id
    # security_list_ids = var.subnet_security_list_ids
}

resource "oci_core_subnet" "private_bsa_subnet" {
    #Required
    cidr_block = "192.168.2.0/24"
    compartment_id = var.root_compartment_id
    vcn_id = oci_core_vcn.main_vcn.id
    display_name = "Private BSA Subnet"

    # TBA
    # prohibit_internet_ingress = var.subnet_prohibit_internet_ingress
    # prohibit_public_ip_on_vnic = var.subnet_prohibit_public_ip_on_vnic
    # route_table_id = oci_core_route_table.test_route_table.id
    # security_list_ids = var.subnet_security_list_ids
}