# Reference: https://github.com/terraform-providers/terraform-provider-oci/blob/master/examples/load_balancer/lb_full/lb_full.tf
# 10Mbps is the maxium free tier limit
resource "oci_load_balancer" "lb1" {
  shape          = "Flexible"
  compartment_id = var.root_compartment_id

  subnet_ids = [
    oci_core_subnet.public_bsa_subnet.id,
    oci_core_subnet.private_bsa_subnet.id,
  ]

  network_security_group_ids = [
      oci_vcn_network_security_group.public_network_security_group
  ]

  display_name = "load_balancer"
  reserved_ips {
    id = oci_core_public_ip.test_reserved_ip.id
  }

  shape_details {
      minimum_bandwidth_in_mbps = 10
      maximum_bandwidth_in_mbps = 10
  }
}

# Backend sets, which consist of backends (shocker!)
resource "oci_load_balancer_backend_set" "lb-bes-http" {
  name             = "lb-bes-https"
  load_balancer_id = oci_load_balancer.lb1.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

# HTTP Listener
resource "oci_load_balancer_listener" "lb-listener1" {
  load_balancer_id         = oci_load_balancer.lb1.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.lb-bes-http.name
  hostname_names           = [oci_load_balancer_hostname.test_hostname1.name, oci_load_balancer_hostname.test_hostname2.name]
  port                     = 80
  protocol                 = "HTTP"
  rule_set_names           = [oci_load_balancer_rule_set.test_rule_set.name]

  connection_configuration {
    idle_timeout_in_seconds = "2"
  }
}

# TODO - Configure SSL and port 443 database backend set

output "lb_ip" {
    value = oci_load_balancer.lb1.ip_address_details[0]
}