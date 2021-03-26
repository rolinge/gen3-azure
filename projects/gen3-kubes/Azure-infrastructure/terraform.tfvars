location            = "West US 2"
cluster_name        = "k8sgen3cg"
#This resource group is for the kubernetes resources
resource_group_name = "k8s-gen3-cg"
POSTGRES_PASSWORD = "hhey77834kefiu&wb@"
commons_url = "https://k8sgen3dev-cg.optum.com"
max_count = 5
api_server_authorized_ip_ranges = ["168.183.0.0/16", "149.111.0.0/16", "128.35.0.0/16", "161.249.0.0/16", "198.203.174.0/23", "198.203.176.0/22", "198.203.180.0/23"]

hdiHeadNodeSize = "STANDARD_DS13_V2"
hdiWorkerNodeSize = "STANDARD_DS14_V2"
blobindexfunction_version = "g3kubes-cg"
