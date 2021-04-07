
locals {
  # Ids for multiple sets of EC2 instances, merged together
  registry_username = "gen3registryoptum"
  registry_password = "F1EnKmQH7dGfWhGMr58YvgL/J=h9U0Cg"
  registry_hostname = "gen3registryoptum.azurecr.io"
}

variable "environment" {
  default = "dev"
}

variable "dns" {
  default = "dns"
}

variable "resource_group_name" {
  description = "(Required) Resource group to build k8s cluster."
  type        = string
}

variable "location" {
  description = "The location to deploy resources to."
  default     = "eastus"
}

variable "public_ssh_key" {
  description = "A custom ssh key to control access to the AKS cluster"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDgS2v7p4M4wpUIP1sNoE+GaKHud4Qyk1Dp/VvCc3X2EEDjRmuaTce9mTyChrvI/P6MqZBY59Cza+84KCvMuW3gju8FncLjcyM8JSc6lBiFQkkaYpLtg7Qt/jBRTHxhwlniQpyw+eDpbxRafg1O5aUTok3Rmw8BlbsS6v2xRGAqsCydWxVO9vfkxQCr2qyCyhJmrXlOM/038KHVqCYHtROKoSZYbVJdFr3erEAfUkzemjYy+eR5eSIQoBPkMIN16WMMcS79uQsDq+BPJTUdEI1d3XLgJ7nDTsjujZTku1YXFEymM0tuhDj8WRe/SO0SEEMcJeAXtWvzJYUFtc65wIZcTH+Ov8nYjSEv8dVf//b2BmQWEjFJ3OStqcd83mZ62dIhWImxeYIUGO4+DX2vQ6E+Y7L8/W1oYfvaRdoZw/jIpsCeABoqzaw14biSXrOEmLeGWBB9HBxYHsd1kIbOaO2AjmzrjROPfM35FHlOk9H3xoRsSvpwmz//jhXeXw+HpikGHdTSxBQqO3gos90FxGnPA9uPBAU1Fr+0Wa+bPOsjMDEAgcJrDREH6ehHyCGHbpFOw1xcB8CriuUeAjdDza+ReIA8x9HpAENMUAkOTuK4+oi/Du0/liu73GF9VM/TqQTjpQePvfFghcksW/wbu8ZrqF9/btpFThrmACo1kAQM7w== rolinger@optumgenomixoutlook.onmicrosoft.com"
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
  }
}

variable data_factory_runtime_core_count {
  default = 8
  description = "The number of cores used in the runtime service.  Valid values are 8, 16, 32, 48, 80, 272"
}

variable data_factory_runtime_ttl {
  default = 30
  description = "The number of minutes that the data factory runtime will wait for a new job before exiting"
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
  default     = ["168.183.0.0/16", "149.111.0.0/16", "128.35.0.0/16", "161.249.0.0/16", "198.203.174.0/23", "198.203.176.0/22", "198.203.180.0/23", "75.73.11.0/24"]
}
variable "vm_size" {
  description = "Size of VM"
  type        = string
  default     = "Standard_B2ms"
}
variable "disk_size_gb" {
  description = "OS disk (disk00) size, in GB.  Standard disks are billed at the following tiers:  32G, 64G, 128G, 256G, 512G, 1024G, 2048G, and 4096G"
  type        = string
  default     = "64"
}
