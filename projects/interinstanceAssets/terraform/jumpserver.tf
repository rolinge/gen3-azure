# Generate passwords that the user can choose to use
module "jumpserver_password" {
  source = "./modules/password_module"
}

resource "azurerm_virtual_machine" "jumpserver" {
  name                             = format("vm-jump-%s",random_string.uid.result)
  location                         = azurerm_resource_group.rg.location
  resource_group_name              = azurerm_resource_group.rg.name
  network_interface_ids            = [azurerm_network_interface.jumpserver.id]
  vm_size                          = var.vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = format("jump-%s",random_string.uid.result)
    caching           = "ReadWrite"
    disk_size_gb      = var.disk_size_gb
    managed_disk_type = "StandardSSD_LRS"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "jumpserver"
    admin_username = "osadmin"
    admin_password = module.jumpserver_password.password
    custom_data    = data.template_cloudinit_config.config.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.cg.primary_blob_endpoint
  }
}

# Render the script to install the anvil application, docker, config, etc
data "template_file" "install_jump" {
  template = "${file("${path.module}/scripts/install_jump.sh.tpl")}"
  vars = {
    #fqdn          = azurerm_public_ip.publicip01.fqdn
    #email_address = var.email_address
    #app_service_default_hostname ="https://${azurerm_app_service.minio.default_site_hostname}"
    #storage_account_name = azurerm_storage_account.gen3.name
    #storage_account_key = azurerm_storage_account.gen3.primary_access_key
    resource_group_name = azurerm_resource_group.rg.name
  }
}


# Render the cloudinit configuration
data "template_cloudinit_config" "config" {
  # cloudinit has a limit of 16kb (after gzip'd)
  gzip          = true
  base64_encode = true

//  part {
//    content_type = "text/x-shellscript"
//    content      = file("${path.module}/scripts/harden_os.sh")
//  }

  part {
    filename     = "install_jump.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.install_jump.rendered
  }
}
//# Lookup the DNS A record set for our VM
//data "dns_a_record_set" "vm01" {
  //host = azurerm_public_ip.publicip01.fqdn
//}
resource "azurerm_network_interface" "jumpserver" {
name                  = format("vm-nic-%s",random_string.uid.result)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "jumpservernic1"
    subnet_id                     = azurerm_subnet.clinicogenomics_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
