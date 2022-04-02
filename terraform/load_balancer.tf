# Reference: https://github.com/terraform-providers/terraform-provider-oci/blob/master/examples/load_balancer/lb_full/lb_full.tf
# 10Mbps is the maxium free tier limit
resource "oci_load_balancer" "lb1" {
  shape          = "flexible"
  compartment_id = var.root_compartment_id

  subnet_ids = [
    oci_core_subnet.public_bsa_subnet.id
  ]

  network_security_group_ids = [
      oci_core_network_security_group.public_network_security_group.id
  ]

  display_name = "load_balancer"
  # reserved_ips {
  #   id = oci_core_public_ip.test_reserved_ip.id
  # }

  shape_details {
      minimum_bandwidth_in_mbps = 10
      maximum_bandwidth_in_mbps = 10
  }
}

# Backend sets, which consist of backends (shocker!)
resource "oci_load_balancer_backend_set" "lb-bes-http" {
  name             = "lb-bes-http"
  load_balancer_id = oci_load_balancer.lb1.id
  policy           = "ROUND_ROBIN"

  # We use 22 as a health check because port 80 will only be open temporarily to generate/renew SSL certificates
  health_checker {
    port                = "22"
    protocol            = "TCP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

# Add the Apache Server (compute instance) to the backend set
resource "oci_load_balancer_backend" "web_server" {
    backendset_name = oci_load_balancer_backend_set.lb-bes-http.name
    ip_address = oci_core_instance.utility_instance.private_ip
    load_balancer_id = oci_load_balancer.lb1.id
    port = 80
}

# HTTP Listener
resource "oci_load_balancer_listener" "lb-listener1" {
  load_balancer_id         = oci_load_balancer.lb1.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.lb-bes-http.name
  # As no hostnames are given, this will forward all traffic on port 80 to the backend set
  port                     = 80
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "2"
  }
}

# Configure SSL and port 443 database backend set
resource "oci_load_balancer_listener" "lb-listener2" {
  load_balancer_id         = oci_load_balancer.lb1.id
  name                     = "https"
  default_backend_set_name = oci_load_balancer_backend_set.lb-bes-http.name
  # As no hostnames are given, this will forward all traffic on port 443 to the backend set
  port                     = 443
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "2"
  }

  # This was added after initial creation in the GUI, adding here to make it easier in the future
  ssl_configuration {
    certificate_ids                   = [] 
    certificate_name                  = "bsa-cert-4" 
    cipher_suite_name                 = "oci-default-ssl-cipher-suite-v1" 
    protocols                         = [
        "TLSv1.2",
    ] 
    server_order_preference           = "DISABLED"
    trusted_certificate_authority_ids = []
    verify_depth                      = 1 
    verify_peer_certificate           = false 
  }
}

# Backend sets, which consist of backends (shocker!)
resource "oci_load_balancer_backend_set" "lb-bes-https" {
  name             = "lb-bes-https"
  load_balancer_id = oci_load_balancer.lb1.id
  policy           = "ROUND_ROBIN"

  # We use 22 as a health check because port 80 will only be open temporarily to generate/renew SSL certificates
  health_checker {
    port                = "80"
    protocol            = "TCP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

# Add the Autonomous database as a backend
resource "oci_load_balancer_backend" "adb" {
    backendset_name = oci_load_balancer_backend_set.lb-bes-https.name
    ip_address = "130.35.144.65"
    load_balancer_id = oci_load_balancer.lb1.id
    port = 443
}

output "lb_ip" {
    value = oci_load_balancer.lb1.ip_address_details[0]
}