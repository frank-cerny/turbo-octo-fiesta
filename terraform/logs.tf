resource "oci_logging_log_group" "lb_error_log_group" {
    compartment_id = var.root_compartment_id
    display_name = "lb_error_log_group"
    description = "Log group for load balancer error logs"
}

resource "oci_logging_log_group" "lb_access_log_group" {
    compartment_id = var.root_compartment_id
    display_name = "lb_access_log_group"
    description = "Log group for load balancer access logs"
}

resource "oci_logging_log_group" "vcn_flow_private_subnet_log_group" {
    compartment_id = var.root_compartment_id
    display_name = "vnc_flow_private_subnet_log_group"
    description = "Log group for VCN flow logs (private subnet)"
}

resource "oci_logging_log_group" "vcn_flow_public_subnet_log_group" {
    compartment_id = var.root_compartment_id
    display_name = "vnc_flow_public_subnet_log_group"
    description = "Log group for VCN flow logs (public subnet)"
}