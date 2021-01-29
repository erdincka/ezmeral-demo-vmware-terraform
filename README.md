# ECP Vmware-Terraform

## Overview

### Setup HPE Ezmeral Container Platform (ECP) demo environment on Vmware vSphere with Terraform

This project makes it easy to setup HPE Container Platform demo/trial environments on Vmware, using [AWS demo scripts](https://github.com/bluedata-community/bluedata-demo-env-aws-terraform) to enable same learning/trial functionality.

### Pre-requisities

Following tools are needed to use the scripts;

- Terraform [download](https://www.terraform.io/downloads.html)
- Packer [download](https://www.packer.io/downloads) (required to create VM template)
- python3
- pip3
- ssh-keygen
- nc
- curl

### Initialize with your Vmware credentials

vSphere environment (tested with ESXi 7.0.1, VCSA 7.0.1)

- Create
  - Datacenter
  - Cluster
  - Resource Pool
- DHCP should be enabled on the network and VMs should be accessible by your local machine
- DHCP should register DNS resolution (or manually provide DNS resolution for allocated IPs)
  
### Update variables for your environment

Fill in the environment variables in ./etc/my_env.sh-template and save it as ./etc/my_env.sh
- centos_iso_url is a valid URL (ftp/http/https) to download CentOS ISO image (tested with 7.9)
- centos_iso_path is the pathname for local CentOS ISO image file (ie, "./CentOS-7-x86_64-Minimal-2009.iso")
- centos_iso_checksum is sha256 checksum for the file above (ie, "sha256:07b94e6b1a0b0260b94c83d6bb76b26bf7a310dc78d7a9c7432809fb9bc6194a")

#### Update ./etc/bluedata_infra.tfvars

- epic_dl_url (should be set in ./etc/my_env.sh)
- domain (should be set in ./etc/my_env.sh)
- (OPTIONAL)
  - Change project_id (also will be set to dns name for gateway)
  - Change options (create AD server, NFS server, External MapR cluster (not implemented yet), add GPU nodes (not implemented yet) etc)
  - Change VM sizes to fit in your environment
  - DO NOT enable RDP host, shouldn't be needed in local deployment (please open an issue if you think it is required)

## Deploy
```
./bin/vmware_create_new.sh
```
This step might take somewhere between 45 minutes to 2 hours, please monitor the script output, and follow up guides in upstream [repo](https://github.com/hpe-container-platform-community/hcp-demo-env-aws-terraform#further-documentation).

## Customizing resources and scenarios

You can edit ./etc/bluedata_infra.tfvars to choose some options, such as enabling RDP server, AD server, NFS server etc.

If you wish to re-configure, make changes and run ```terraform apply``` or re-run ```./bin/vmware_create_new.sh``` to reflect these changes in the resources.

If you want clean installation and not all the demo scenarios, comment out following line in ./bin/vmware_create_new.sh:
```
mv "./etc/postcreate.sh_template" "./etc/postcreate.sh"
```

Alternatively, you can switch to "./hcp-demo-env-aws-terraform" folder and run scripts in ./bin directory (please run scripts on this upstream repo top level directory, ie, within ./hcp-demo-env-aws-terraform).

For example to install all available catalog images, you can run:
./bin/experimental/epic_catalog_image_install_all.sh

## TODO
- [ ] Enable GPU nodes
- [ ] Enable MapR cluster creation

Please send comments/issues/suggestions through github (as we are not monitoring other places, such as Stackoverflow etc).

