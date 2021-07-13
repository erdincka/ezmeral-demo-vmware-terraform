# Controller VM
resource "vsphere_virtual_machine" "controller" {
  name                  = "${var.project_id}-ctrl"
  resource_pool_id      = data.vsphere_resource_pool.pool.id
  # custom_data           = base64encode(file(pathexpand(var.cloud_init_file)))
  datastore_id          = data.vsphere_datastore.datastore.id
  num_cpus              = var.ctr_instance_cpu
  memory                = var.ctr_instance_memory
  guest_id              = data.vsphere_virtual_machine.template.guest_id
  scsi_type             = data.vsphere_virtual_machine.template.scsi_type
  network_interface {
    network_id = data.vsphere_network.network.id
  }
  disk {
      label               = "${var.project_id}-ctrl-os-disk"
      size                = "400"
      thin_provisioned    = true
  }
  # clone from template
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = "${var.project_id}-ctrl"
        domain = var.domain
        time_zone = var.timezone
      }
      network_interface { } // use dhcp
    }
  }
  /********** Data Disks **********/
  disk {
    label               = "${var.project_id}-ctrl-disk1"
    size                = 512
    unit_number         = 1
  }
  disk {
    label               = "${var.project_id}-ctrl-disk2"
    size                = 512
    unit_number         = 2
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y -q cloud-utils-growpart",
      "sudo growpart /dev/sda 3",
      "sudo xfs_growfs /"
    ]
    connection {
      host     = self.default_ip_address
      user     = var.user
      private_key = file(var.ssh_prv_key_path)
    }
  }
}
