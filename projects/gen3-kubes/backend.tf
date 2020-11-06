terraform {
  backend "azurerm" {
    resource_group_name  = "k8s-gen3-tfw2"
    storage_account_name = "k8sgen3tf19336"
    container_name       = "tfstate"
    key                  = "azure-k8s19336.tfstate"
    access_key = "bcQkuWCHwLmN2KeJhaT8+tyICjAEVI+ET6LdonKfGhTyzqOMnGU11jOvItPPoKMMuj1C5lNa/pGRS5NAlky60Q=="
  }
  required_version = ">= 0.13"
}

#az storage account create --resource-group rolinge-01 --location eastus --name aksrmo --subscription=29bd0546-ff5b-437c-bab6-aea5fc7e5653
# az storage account keys list --account-name aksrmo --subscription=29bd0546-ff5b-437c-bab6-aea5fc7e5653
#az storage container create --name tfstate --account-name aksrmo --subscription=29bd0546-ff5b-437c-bab6-aea5fc7e5653 --account-key "Sa57eVm55kl9pSsnNv1IJyxDIv2mS895jrCSR63HurwYOFCFPjJosqgCsdg0oMlgcv8wf/wDHR/fpO0JlEabKQ=="
