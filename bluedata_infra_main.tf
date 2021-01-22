provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "template_file" "cli_logging_config_template" {
  template = file("etc/hpecp_cli_logging.conf")
  vars = {
    hpecp_cli_log_file = "${abspath(path.module)}/generated/hpecp_cli.log"
  }
}

resource "local_file" "cli_logging_config_file" {
  filename = "${path.module}/generated/hpecp_cli_logging.conf"
  content =  data.template_file.cli_logging_config_template.rendered
}

resource "local_file" "ca-cert" {
  filename = "${path.module}/generated/ca-cert.pem"
  content =  var.ca_cert
}

resource "local_file" "ca-key" {
  filename = "${path.module}/generated/ca-key.pem"
  content =  var.ca_key
}

# Vsphere resources
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_datastore" "datastore" {
  name = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name = var.resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}
