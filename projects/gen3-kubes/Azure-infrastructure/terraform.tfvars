location     = "West US"
cluster_name = "mycluster"
#This resource group is for the kubernetes resources
resource_group_name             = "gen3"
commons_dns_name                = "mysite"
commons_dns_suffix              = "example.com"
environment                     = "dev"
max_count                       = 5
api_server_authorized_ip_ranges = ["0.0.0.0/0"]
aks_k8s_version                 = "1.19.7"

hdinsight_node_username   = "gen3_hdinsight_nodes"
hdiHeadNodeSize           = "STANDARD_DS13_V2"
hdiWorkerNodSize          = "STANDARD_DS14_V2"
blobindexfunction_version = "develop"
sslCertificatefile        = "assets/certificate.pfx"
sslCertificatePassword    = ""
