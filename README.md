# ECP Vmware-Terraform

## Overview

### Setup HPE Ezmeral Container Platform (ECP) demo environment on Vmware vSphere with Terraform

This project makes it easy to setup HPE Container Platform demo/trial environments on Vmware, using [AWS demo scripts](https://github.com/bluedata-community/bluedata-demo-env-aws-terraform) to enable same learning/trial functionality.

### Pre-requisities

- Terraform [download](https://www.terraform.io/downloads.html)

### Initialize with your Azure credentials


### Update variables for your environment

#### Update ./etc/bluedata_infra.tfvars

- epic_dl_url: 
- (OPTIONAL)
  - Change project_id (which will be used as resource_group_name and prefix for created resources)
  - Change options (create AD server, NFS server, External MapR cluster (not implemented yet), add GPU nodes (not implemented yet) etc)
  - Change VM sizes to fit in your environment

## Deploy
```
./bin/azure_create_new.sh
```
This step might take somewhere between 45 minutes to 2 hours, please monitor the script output, and follow up guides in upstream [repo](https://github.com/hpe-container-platform-community/hcp-demo-env-aws-terraform#further-documentation).

## Customizing resources and scenarios

You can edit ./etc/bluedata_infra.tfvars to choose some options, such as enabling RDP server, AD server, NFS server etc.

If you wish to re-configure, make changes and run ```terraform apply``` to reflect these changes in the resources.

If you want clean installation and not all the demo scenarios, comment out following line in ./bin/azure_create_new.sh:
```
mv "./etc/postcreate.sh_template" "./etc/postcreate.sh"
```

Alternatively, you can switch to "./hcp-demo-env-aws-terraform" folder and run scripts in ./bin directory (please run scripts on this upstream repo top level directory, ie, within ./hcp-demo-env-aws-terraform).

For example to install all available catalog images, you can run:
./bin/experimental/epic_catalog_image_install_all.sh

## TODO
- [ ] Enable GPU nodes
- [ ] Enable MapR cluster creation
- [ ] Enable AKS creation

Please send comments/issues/suggestions through github (as we are not monitoring other places, such as Stackoverflow etc).

