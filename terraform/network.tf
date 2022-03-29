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

# Network Security Groups
resource "oci_core_network_security_group" "private_network_security_group" {
    compartment_id = var.root_compartment_id
    vcn_id = oci_core_vcn.main_vcn.id
    display_name = "Private NSG"
}

resource "oci_core_network_security_group" "public_network_security_group" {
    compartment_id = var.root_compartment_id
    vcn_id = oci_core_vcn.main_vcn.id
    display_name = "Public NSG"
}

# Examples of NSG Rules: https://github.com/oracle/terraform-provider-oci/blob/master/examples/networking/network_security_group/network_security_group.tf
# TODO Make creating new rules easier (module or foreach?)

# NSG Rules
# Ingress Rules for Private Subnet
# Allow Port 80 from the public NSG only (not from the public internet)
resource "oci_core_network_security_group_security_rule" "private_public_network_security_group_security_rule_ingress_80" {
    network_security_group_id = oci_core_network_security_group.private_network_security_group.id
    direction = "INGRESS"
    # 6 = TCP
    protocol = "6"

    description = "Allow HTTP Web Traffic into Private Subnet"
    destination = oci_core_network_security_group.private_network_security_group.id
    destination_type = "NETWORK_SECURITY_GROUP"

    source = oci_core_network_security_group.public_network_security_group.id
    source_type = "NETWORK_SECURITY_GROUP"
    # Stateless rules are uni-directional (egress rules must also be added then )
    stateless = true
    tcp_options {
        destination_port_range {
            max = 80
            min = 80
        }
        # As we have left off source port ranges, all ports are valid from a source perspective
    }
}

# Allow Port 443 from the public NSG only (not from the public internet)
resource "oci_core_network_security_group_security_rule" "private_public_network_security_group_security_rule_ingress_443" {
    network_security_group_id = oci_core_network_security_group.private_network_security_group.id
    direction = "INGRESS"
    # 6 = TCP
    protocol = "6"

    description = "Allow HTTP Web Traffic into Private Subnet"
    destination = oci_core_network_security_group.private_network_security_group.id
    destination_type = "NETWORK_SECURITY_GROUP"

    source = oci_core_network_security_group.public_network_security_group.id
    source_type = "NETWORK_SECURITY_GROUP"
    # Stateless rules are uni-directional (egress rules must also be added then )
    stateless = true
    tcp_options {
        destination_port_range {
            max = 443
            min = 443
        }
        # As we have left off source port ranges, all ports are valid from a source perspective
    }
}

# Allow Port 22 from the public NSG only 
resource "oci_core_network_security_group_security_rule" "private_public_network_security_group_security_rule_ingress_22" {
    network_security_group_id = oci_core_network_security_group.private_network_security_group.id
    direction = "INGRESS"
    # 6 = TCP
    protocol = "6"

    description = "Allow SSH Traffic into Private Subnet from Public Subnet"
    destination = oci_core_network_security_group.private_network_security_group.id
    destination_type = "NETWORK_SECURITY_GROUP"

    source = oci_core_network_security_group.public_network_security_group.id
    source_type = "NETWORK_SECURITY_GROUP"
    # Stateless rules are uni-directional (egress rules must also be added then )
    stateless = true
    tcp_options {
        destination_port_range {
            max = 22
            min = 22
        }
        # As we have left off source port ranges, all ports are valid from a source perspective
    }
}

# Allow all ports from private -> public NSG
resource "oci_core_network_security_group_security_rule" "private_public_network_security_group_security_rule_egress_all" {
    network_security_group_id = oci_core_network_security_group.private_network_security_group.id
    direction = "EGRESS"
    # 6 = TCP
    protocol = "6"

    description = "Allow HTTP Web Traffic into Private Subnet"
    destination = oci_core_network_security_group.public_network_security_group.id
    destination_type = "NETWORK_SECURITY_GROUP"

    source = oci_core_network_security_group.private_network_security_group.id
    source_type = "NETWORK_SECURITY_GROUP"
    # Stateless rules are uni-directional 
    stateless = true
}

# # Security Lists (for Bastion subnet)
# # Security list to allow 22 ingress, everything egress (to allow for port forwarding sessions and managed SSH sessions)
# resource "oci_core_security_list" "bastion_security_list_to_private" {
#     #Required
#     compartment_id = var.compartment_id
#     vcn_id = oci_core_vcn.main_vcn.id
#     display_name = "Bastion Subnet Security List - 22"
#     egress_security_rules {
#         destination = "192.168.2.0/24"
#         protocol = "TCP"
#         description = "EGRESS Rules"
#         destination_type = "CIDR BLOCK"
#         stateless = false
#         # As we have left off the egress TCP block, all TCP egress is allowed
#     }
#     ingress_security_rules {
#         protocol = "TCP"
#         source = var.security_list_ingress_security_rules_source
#         description = "INGRESS Rules"
#         source_type = "CIDR BLOCK"
#         stateless = false
#         tcp_options {
#             max = 22
#             min = 22
#             source_port_range {
#                 max = 22
#                 min = 22
#             }
#         }
# }

# TODO NAT to connect private subnet to internet (mono-directional)

# Internet gateway to connect public subnet to the internet (bi-directional)
resource "oci_core_internet_gateway" "internet_gateway" {
    compartment_id = var.root_compartment_id
    vcn_id = oci_core_vcn.main_vcn.id
    enabled = true
    display_name = "Internet Gateway"
}

# Routing table and rules for public subnet to access internet gateway
resource "oci_core_route_table" "internet_route_table" {
    compartment_id = var.root_compartment_id
    vcn_id = oci_core_vcn.main_vcn.id

    route_rules {
        # Routes private subnet traffic to the private subnet
        network_entity_id = oci_core_internet_gateway.internet_gateway.id
        description = "Public Internet Traffic"
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
    }

    # Per: https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingroutetables.htm
    # All inter-VCN traffic is automatically routed for us, so no need to create a rule for that
}

resource "oci_core_route_table_attachment" "route_table_attachment_public" {   
  subnet_id = oci_core_subnet.public_bsa_subnet.id
  route_table_id =oci_core_route_table.internet_route_table.id
}