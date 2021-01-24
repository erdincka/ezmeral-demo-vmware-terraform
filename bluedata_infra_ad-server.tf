# AD VM
resource "vsphere_virtual_machine" "ad_server" {
  name                  = "ad_server"
  count                 = var.ad_server_enabled ? 1 : 0
  resource_pool_id      = data.vsphere_resource_pool.pool.id
  datastore_id          = data.vsphere_datastore.datastore.id
  num_cpus              = var.ad_instance_cpu
  memory                = var.ad_instance_memory
  guest_id              = data.vsphere_virtual_machine.template.guest_id
  scsi_type             = data.vsphere_virtual_machine.template.scsi_type
  network_interface {
    network_id = data.vsphere_network.network.id
  }
  disk {
      label               = "ad_server-os-disk"
      size                = "400"
      thin_provisioned    = true
  }
  # clone from template
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = "ad_server"
        domain = var.domain
        time_zone = var.timezone
      }
      network_interface { } // use dhcp
    }
  }
  provisioner "file" {
    source      = "${var.downstream_repo_dir}/modules/module-ad-server/files/"
    destination = "/home/centos"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y -q cloud-utils-growpart",
      "sudo growpart /dev/sda 2",
      "sudo xfs_growfs /",
      "sudo yum update -y -q",
      "sudo yum install -y -q docker openldap-clients",
      "sudo systemctl enable --now docker",
      "while [ ! -f /home/centos/run_ad.sh ]; do sleep 2; done",
      "/bin/bash /home/centos/run_ad.sh",
      "sleep 120",
      "/bin/bash /home/centos/ldif_modify.sh"
    ]
    connection {
      host     = self.default_ip_address
      user     = var.user
      private_key = file(var.ssh_prv_key_path)
    }
  }
}
