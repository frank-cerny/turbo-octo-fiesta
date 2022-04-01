# Create a free tier compute instance which houses utilities for cert creation with certbot

# Example: https://github.com/oracle/terraform-provider-oci/blob/master/examples/compute/instance/instance.tf

resource "oci_core_instance" "utility_instance" {
    availability_domain = data.oci_identity_availability_domain.ad.name
    compartment_id = var.root_compartment_id
    shape = "VM.Standard.A1.Flex"
    display_name = "Utility Instance"

    create_vnic_details {
        assign_public_ip = false
        display_name = "Utility Instance VNIC"
        nsg_ids = [
            oci_core_network_security_group.private_network_security_group.id
        ]
        private_ip = "192.168.2.50"
        # skip_source_dest_check = var.instance_create_vnic_details_skip_source_dest_check
        subnet_id = oci_core_subnet.private_bsa_subnet.id
    }

    agent_config {
      # This allows us to use managed SSH sessions from a bastion host (instead of port forwarding)
      plugins_config  {
        desired_state = "ENABLED"
        name          = "Bastion"
      }
  }

    # TODO Add a real key! (Via variables, do NOT check in LOL)
    # metadata = {
    #     ssh_authorized_keys = "ssh-rsa == TEMP"
    # }

    shape_config {
        # BASELINE_1_1 = non-burstable
        baseline_ocpu_utilization = "BASELINE_1_1"
        memory_in_gbs = 24
        ocpus = 4
    }

    source_details {
        # Get the first supported image from the list
        source_id = var.utility_image_source_id
        source_type = "image"
        # Use the default boot volume size (we will add block storage below to extend the storage capacity)
    }
}

# Create Boot Volumes and Storage Volumes for the Instance
# Reference: https://docs.oracle.com/en-us/iaas/Content/Block/Concepts/overview.htm

resource "oci_core_volume" "block_volume_paravirtualized" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.root_compartment_id
  display_name        = "Paravirtualized Block Volume"
  size_in_gbs         = "100"
}

resource "oci_core_volume_attachment" "block_volume_attach_paravirtualized" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.utility_instance.id
  volume_id       = oci_core_volume.block_volume_paravirtualized.id
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}

# # Borrowed and modified from: https://github.com/terraform-providers/terraform-provider-oci/blob/master/examples/load_balancer/lb_full/lb_full.tf
# variable "user-data" {
#   default = <<EOF
# #!/bin/bash -x
# echo '################### webserver userdata begins #####################'
# touch ~opc/userdata.`date +%s`.start
# # echo '########## yum update all ###############'
# sudo yum update -y
# echo '########## basic webserver ##############'
# sudo yum install -y httpd
# sudo systemctl start  httpd.service
# sudo systemctl enable  httpd.service
# echo '<html><head></head><body>' > /var/www/html/index.html
# echo 'Hello World' > /var/www/html/index.html
# sudo firewall-cmd --add-service=http --zone=public --permanent
# sudo firewall-cmd --reload
# touch ~opc/userdata.`date +%s`.finish
# echo '################### webserver userdata ends #######################'
# EOF

# }