terraform {
  backend "azurerm" {
    resource_group_name = "k8s-gen3-tfw2"
    #    storage_account_name = "k8sgen3tf19336"
    #    container_name       = "tfstate"
    #    key                  = "azure-k8s-carlos.tfstate"
    #    access_key = "bcQkuWCHwLmN2KeJhaT8+tyICjAEVI+ET6LdonKfGhTyzqOMnGU11jOvItPPoKMMuj1C5lNa/pGRS5NAlky60Q=="
  }
  required_version = ">= 0.13"
}