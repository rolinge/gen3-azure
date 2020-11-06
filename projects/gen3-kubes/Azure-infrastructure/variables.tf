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

variable "storage_account_name" {
  type        = string
  description = "The name of the storage account"
  default     = "rolinge-redbox-aks"
}

variable "agent_count" {
  default = 2
}

variable "disk_size" {
  default = 30
}

variable "max_count" {
  default = 4
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
  default = "1.18.8"
}

variable "agents_size" {
  default     = "Standard_D2s_v3"
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
  default     = "7"
}

variable "tags" {
  default = {
    environment = "nonprod"
    costcenter  = "dcermo"
    asset       = "aks"
  }
}

# "168.183.0.0/16", "149.111.0.0/16", "128.35.0.0/16", "161.249.0.0/16", "198.203.174.0/23", "198.203.176.0/22", "198.203.180.0/23"
# Use these permitted IP ranges to setup your network profile.
variable "api_server_authorized_ip_ranges" {
  description = "The IP ranges to whitelist for incoming traffic to the masters"
  type        = list
  default     = ["168.183.0.0/16", "149.111.0.0/16", "128.35.0.0/16", "161.249.0.0/16", "198.203.174.0/23", "198.203.176.0/22", "198.203.180.0/23"]
}
