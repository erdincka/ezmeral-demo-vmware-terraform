# Worker VMs
resource "vsphere_virtual_machine" "workers" {
  count                 = var.worker_count
  name                  = "${var.project_id}-worker${count.index + 1}"
  resource_pool_id      = data.vsphere_resource_pool.pool.id
  datastore_id          = data.vsphere_datastore.datastore.id
  num_cpus              = var.wkr_instance_cpu
  memory                = var.wkr_instance_memory
  guest_id              = data.vsphere_virtual_machine.template.guest_id
  scsi_type             = data.vsphere_virtual_machine.template.scsi_type
  network_interface {
    network_id = data.vsphere_network.network.id
  }
  disk {
      label               = "${var.project_id}-worker${count.index + 1}-os-disk"
      size                = "400"
      thin_provisioned    = true
  }
  # clone from template
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = "${var.project_id}-worker${count.index + 1}"
        domain = var.domain
        time_zone = var.timezone
      }
      network_interface { } // use dhcp
    }
  }
  /********** Data Disks **********/
  disk {
    label               = "${var.project_id}-worker${count.index + 1}-disk1"
    size                = 1024
    unit_number         = 1
  }
  disk {
    label               = "${var.project_id}-worker${count.index + 1}-disk2"
    size                = 1024
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
