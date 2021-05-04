#
# Set this to something DNS/screen friendly
# This will be used for external host and resource naming
#
project_id         = "ecp"
region             = "none"

embedded_df = true
epic_options = "--skipeula --default-password admin123" 
epic_dl_url = ""
epid_dl_url_needs_presign = false
worker_count = 3

### For AWS script compatibility
az = "null"
client_cidr_block = "10.1.1.0/24" # Dummy cidr
ssh_prv_key_path = "./generated/controller.prv_key"
ssh_pub_key_path = "./generated/controller.pub_key"
subnet_cidr_block = "10.1.2.0/24" # Dummy cidr
vpc_cidr_block = "10.1.3.0/24" # Dummy cidr
rdp_server_enabled = false
ad_server_enabled = true

