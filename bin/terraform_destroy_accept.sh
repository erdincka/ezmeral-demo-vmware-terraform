#!/usr/bin/env bash
set -eu
downstream_repodir="./hcp-demo-env-aws-terraform"
source ./etc/my_env.sh

# remove ssh keys
[ -f ./generated/output.json ] && (grep "ssh -o" ./generated/output.json | cut -d'@' -f2 | cut -d'"' -f1 | xargs -n 1 ssh-keygen -R)
# destroy resources
eval "terraform destroy --auto-approve=true \
  -var-file=./etc/bluedata_infra.tfvars \
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
  -var 'domain=${domain}' \
  -var 'epic_dl_url=${epic_dl_url}'"

# clean up
rm -rf "./generated"
[ -d ${downstream_repodir} ] && rm -rf "${downstream_repodir}"

echo "Please remove the template VM from vCenter!"

