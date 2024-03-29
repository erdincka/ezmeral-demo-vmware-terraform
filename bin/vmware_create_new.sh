#!/usr/bin/env bash

set -e # abort on error
set -u # abort on undefined variable

downstream_repodir="./hcp-demo-env-aws-terraform"
downstream_repourl="https://github.com/hpe-container-platform-community/hcp-demo-env-aws-terraform"

[ -d ${downstream_repodir} ] || git clone "${downstream_repourl}" "${downstream_repodir}"
### Fix for VM disk naming
sed -i'' -e 's/nvme1n1/sdb/g' -e 's/nvme2n1/sdc/g' ${downstream_repodir}/bin/experimental/03_k8sworkers_add.sh
sed -i'' -e 's/nvme1n1/sdb/g' -e 's/nvme2n1/sdc/g' ${downstream_repodir}/bin/experimental/epic_workers_add.sh  
# workaround for the script
# sed -i'' 's/apt/apt \-y/g' ${downstream_repodir}/modules/module-rdp-server-linux/ca-certs-setup.sh
# don't require aws cli
sed -i '/command -v aws/,+5d' ${downstream_repodir}/scripts/check_prerequisites.sh

source "${downstream_repodir}/scripts/functions.sh"
./scripts/check_prerequisites.sh # for Vmware

if [[ ! -f  "./generated/controller.prv_key" ]]; then
   [[ -d "./generated" ]] || mkdir "./generated"
   ssh-keygen -m pem -t rsa -N "" -f "./generated/controller.prv_key"
   mv "./generated/controller.prv_key.pub" "./generated/controller.pub_key"
   chmod 600 "./generated/controller.prv_key"
fi

source "./etc/my_env.sh"
SSH_PUB_KEY=$(cat ./generated/controller.pub_key)

eval "sed -e 's|SSHKEY|\"${SSH_PUB_KEY}\"|g' -e 's|TIMEZONE|\"${timezone}\"|g' ./etc/ks.cfg-template" > ./etc/ks.cfg

# Create a template VM
# Install CentOS 7.x
# Run https://gist.github.com/efeldhusen/4bea2031525203b1658b444f4709c12c#file-vmware-template-centos7-sh
# Convert to template in vCenter
[ -f ./generated/template_uploaded ] || eval "packer build \
  -var 'vsphere-server=${vsphere_server}' \
  -var 'vsphere-user=${vsphere_user}' \
  -var 'vsphere-password=${vsphere_password}' \
  -var 'vsphere-datacenter=${vsphere_datacenter}' \
  -var 'vsphere-cluster=${vsphere_cluster}' \
  -var 'vsphere-resourcepool=${vsphere_resourcepool}' \
  -var 'vsphere-datastore=${vsphere_datastore}' \
  -var 'vsphere-network=${vsphere_network}' \
  -var 'iso-path=${centos_iso_path}' \
  -var 'iso-url=${centos_iso_url}' \
  -var 'iso-checksum=${centos_iso_checksum}' \
  -var 'ssh-prv-key=./generated/controller.prv_key' \
   ./etc/centos7-packer.json" 

touch ./generated/template_uploaded

print_header "Starting to create infrastructure with Terraform"
# if [[ -f terraform.tfstate ]]; then

#    python3 -mjson.tool "terraform.tfstate" > /dev/null || {
#      echo "The file terraform.tfstate does not appear to be valid json. Aborting."
#      exit 1
#    } 

#    TF_RESOURCES=$(cat terraform.tfstate | python3 -c 'import json,sys;obj=json.load(sys.stdin);print(len(obj["resources"]))')

#    if [[ "$TF_RESOURCES" == "0" ]]; then
#       echo "Found 0 terraform resources in terraform.tfstate - presuming this is a clean envrionment"
#    else
#       print_term_width '='
#       echo "Refusing to create environment because existing ./terraform.tfstate file found."
#       echo "Please destroy your environment (./bin/terraform_destroy.sh) and then remove all terraform.tfstate files"
#       echo "before trying again."
#       print_term_width '='
#       exit 1
#    fi
# fi

[ -f .terraform.lock.hcl ] || terraform init
[ -f ./bluedata_infra_variables.tf ] || ln -s ./hcp-demo-env-aws-terraform/bluedata_infra_variables.tf .

eval "terraform apply -var-file=./etc/bluedata_infra.tfvars \
  -var 'vsphere_server=${vsphere_server}' \
  -var 'vsphere_user=${vsphere_user}' \
  -var 'vsphere_password=${vsphere_password}' \
  -var 'vsphere_datacenter=${vsphere_datacenter}' \
  -var 'vsphere_cluster=${vsphere_cluster}' \
  -var 'vsphere_resourcepool=${vsphere_resourcepool}' \
  -var 'vsphere_datastore=${vsphere_datastore}' \
  -var 'vsphere_network=${vsphere_network}' \
  -var 'centos_iso_url=${centos_iso_url}' \
  -var 'timezone=${timezone}' \
  -var 'epic_dl_url=${epic_dl_url}' \
  -var 'domain=${domain}' \
  -auto-approve=true"

print_header "Output saved to generated/output.json"
terraform output -json > "./generated/output.json"

# echo "Sleeping for 120s to give services a chance to finalize"
# sleep 120

# Now we switch to AWS repo
pushd ${downstream_repodir}
[ ! -d ./generated ] && ln -s ../generated .

print_header "Running ./scripts/post_refresh_or_apply.sh"
./scripts/post_refresh_or_apply.sh

print_header "Installing HCP"
./scripts/bluedata_install.sh

print_header "Installing HPECP CLI on Controller"
./bin/experimental/install_hpecp_cli.sh 

### OPTIONAL: enable for initial env creation
cp "./etc/postcreate.sh_template" "./etc/postcreate.sh"

if [[ -f "./etc/postcreate.sh" ]]; then
   print_header "Found ./etc/postcreate.sh so executing it"
   ./etc/postcreate.sh
else
   print_header "./etc/postcreate.sh not found - skipping."
fi

source "./scripts/variables.sh"
if [[ "$RDP_SERVER_ENABLED" == True && "$RDP_SERVER_OPERATING_SYSTEM" == "LINUX" ]]; then
   print_term_width '-'
   echo "BlueData installation completed successfully with an RDP server"
   echo "Please run ./generated/rdp_credentials.sh for connection details."
   print_term_width '-'
fi

print_term_width '-'
echo "Run ./generated/get_public_endpoints.sh for all connection details."
print_term_width '-'

print_term_width '='

popd
