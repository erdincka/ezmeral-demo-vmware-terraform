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
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name = var.vsphere_resourcepool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Password generator
resource "random_password" "rdp_admin_password" {
  length = 16
  special = true
  override_special = "_%@"
}

data "vsphere_virtual_machine" "template" {
  name          = "CentOS7-Template"
  datacenter_id = data.vsphere_datacenter.dc.id
}
resource "vsphere_virtual_machine" "rdp_server" {
  count         = var.rdp_server_enabled ? 1 : 0
  name          = "dummy-resource"
  resource_pool_id      = data.vsphere_resource_pool.pool.id
  datacenter_id = data.vsphere_datacenter.dc.id
}
