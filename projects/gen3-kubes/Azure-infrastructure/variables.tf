variable "client_id" {
  type        = string
  description = "The name of the client id"
  default = "f8b8b944-81bf-4c76-b460-f9e17beef02d"
}

variable "client_secret" {
  type        = string
  description = "The value of the client secret"
  default     = "XDUjUzCdgBc_TTpVaCChDP41-rNYR21~o4"
 }

variable "agent_count" {
  default = 2
}

variable "commons_url" {
  type          = string
  description   = "The web address of the final site"
}

variable "functionapp" {
  type          = string
  description   = "The local file that has the code for blobindexfunc"
  default       = "assets/blobindexcode.zip"
}

variable "k8s_os_disk_size" {
  default = 128
}

variable "max_count" {
  default = 16
}

variable "POSTGRES_PASSWORD" {
  type    = string
  default = "postgrestest"
}
variable "min_count" {
  default = 2
}

variable "prefix" {
  default = "dce-aks"
}

variable "environment" {
  default = "dev"
}

variable "dns" {
  default = "dns"
}

variable "vnet" {
  default = "vnet"
}

variable cluster_name {
}

variable "resource_group_name" {
  description = "(Required) Resource group to build k8s cluster."
  type        = string
}

variable "location" {
  description = "The location to deploy resources to."
  default     = "eastus"
}

# az aks get-versions --location centralus --output table
variable aks_k8s_version {
  default = "1.19.3"
}

variable "k8_agents_regular" {
  default     = "Standard_D2s_v3"
  description = "The default virtual machine size for the Kubernetes agents"
}
variable "k8_agents_big" {
  default     = "Standard_D4s_v3"
  description = "The default virtual machine size for the Kubernetes agents"
}

variable "public_ssh_key" {
  description = "A custom ssh key to control access to the AKS cluster"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDgS2v7p4M4wpUIP1sNoE+GaKHud4Qyk1Dp/VvCc3X2EEDjRmuaTce9mTyChrvI/P6MqZBY59Cza+84KCvMuW3gju8FncLjcyM8JSc6lBiFQkkaYpLtg7Qt/jBRTHxhwlniQpyw+eDpbxRafg1O5aUTok3Rmw8BlbsS6v2xRGAqsCydWxVO9vfkxQCr2qyCyhJmrXlOM/038KHVqCYHtROKoSZYbVJdFr3erEAfUkzemjYy+eR5eSIQoBPkMIN16WMMcS79uQsDq+BPJTUdEI1d3XLgJ7nDTsjujZTku1YXFEymM0tuhDj8WRe/SO0SEEMcJeAXtWvzJYUFtc65wIZcTH+Ov8nYjSEv8dVf//b2BmQWEjFJ3OStqcd83mZ62dIhWImxeYIUGO4+DX2vQ6E+Y7L8/W1oYfvaRdoZw/jIpsCeABoqzaw14biSXrOEmLeGWBB9HBxYHsd1kIbOaO2AjmzrjROPfM35FHlOk9H3xoRsSvpwmz//jhXeXw+HpikGHdTSxBQqO3gos90FxGnPA9uPBAU1Fr+0Wa+bPOsjMDEAgcJrDREH6ehHyCGHbpFOw1xcB8CriuUeAjdDza+ReIA8x9HpAENMUAkOTuK4+oi/Du0/liu73GF9VM/TqQTjpQePvfFghcksW/wbu8ZrqF9/btpFThrmACo1kAQM7w== rolinger@optumgenomixoutlook.onmicrosoft.com"
}

variable "enable_log_analytics_workspace" {
  type        = bool
  description = "Enable the creation of azurerm_log_analytics_workspace and azurerm_log_analytics_solution or not"
  default     = true
}

variable "log_analytics_workspace_sku" {
  description = "The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018"
  default     = "PerGB2018"
}

variable "log_retention_in_days" {
  description = "The retention period for the logs in days"
  default     = "30"
}

variable "tags" {
  default = {
    environment = "nonprod"
    costcenter  = "clinical"
    asset       = "aks"
  }
}

variable "AZ_SUBSCRIPTION_ID" {
  type        = string
  description = "The subscription to deploy to"
  default     = "21a7a4d3-3641-4382-95a8-85ae72399ceb"
}

variable "AZ_CLIENT_ID" {
  type        = string
  description = "The Client Credentials used for deployment, must have contributor role"
  default     = "bc9ed98e-b121-4bdc-8894-3f21554d4215"
}

variable "AZ_CLIENT_SECRET" {
  type        = string
  description = "The corresponding client secret used for deployment"
}

variable "AZ_TENANT_ID" {
  type        = string
  description = "High level tennant id for the system"
  default     = "db05faca-c82a-4b9d-b9c5-0f64b6755421"
}

# "168.183.0.0/16", "149.111.0.0/16", "128.35.0.0/16", "161.249.0.0/16", "198.203.174.0/23", "198.203.176.0/22", "198.203.180.0/23"
# Use these permitted IP ranges to setup your network profile.
variable "api_server_authorized_ip_ranges" {
  description = "The IP ranges to whitelist for incoming traffic to the masters"
  type        = list
  default     = ["168.183.0.0/16", "149.111.0.0/16", "128.35.0.0/16", "161.249.0.0/16", "198.203.174.0/23", "198.203.176.0/22", "198.203.180.0/23","75.73.11.0/24"]
}

variable "sshKeyPath_hdinsights" {
  type        = string
  default     = "~/.ssh/dbe_rsa.pub"
  description = "Local SSH Key which should be used for the local administrator."
}

variable "hdinsight_node_username" {
  type        = string
  default     = "gen3_hdinsight_nodes"
  description = "Username for Head, Zookeeper, and Worker nodes for the HDInsights Spark Cluster"
}

variable "hdinsight_gw_username" {
  type        = string
  default     = "gen3_hdinsight_gateway"
  description = "Username for HDInsights gateway"
}

variable "hdinsight_gw_password" {
  type        = string
  description = "Password for HDInsights gateway"    
}
