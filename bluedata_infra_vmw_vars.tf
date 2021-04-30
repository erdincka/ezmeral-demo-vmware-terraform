# vSphere settings
variable vsphere_user { }
variable vsphere_password { }
variable vsphere_server { }

variable vsphere_datacenter { }
variable vsphere_cluster { }
variable vsphere_datastore { }
variable vsphere_resourcepool { }
variable vsphere_network { }
variable centos_iso_url { }
variable timezone { }
variable domain { }

variable "downstream_repo_dir" { default = "hcp-demo-env-aws-terraform" }
variable "user" { default = "centos" }

variable gtw_instance_cpu { default = 16 }
variable gtw_instance_memory { default = 16384 }
variable ctr_instance_cpu { default = 16 }
variable ctr_instance_memory { default = 65536 }
variable wkr_instance_cpu { default = 16 }
variable wkr_instance_memory { default = 32768 }
variable rdp_instance_cpu { default = 16 }
variable rdp_instance_memory { default = 16384 }
variable ad_instance_cpu { default = 16 }
variable ad_instance_memory { default = 16384 }
variable nfs_instance_cpu { default = 16 }
variable nfs_instance_memory { default = 16384 }
variable mapr_instance_cpu { default = 16 }
variable mapr_instance_memory { default = 32768 }
variable gpu_instance_cpu { default = 16 }
variable gpu_instance_memory { default = 32768 }

