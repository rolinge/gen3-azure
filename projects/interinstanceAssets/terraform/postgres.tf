resource "azurerm_postgresql_server" "clinicogenomics" {
  name                = format("pg%s", var.environment)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name                     = "GP_Gen5_2"
  storage_mb                   = 81920
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  version                      = "11"
  ssl_enforcement_enabled      = false
  administrator_login          = "postgres"
  administrator_login_password = module.postgres_password.password
  auto_grow_enabled            = true

  public_network_access_enabled = true


  tags = merge(var.tags, local.common_tags)

}

resource "azurerm_postgresql_configuration" "clinicogenomics" {
  name                = "idle_in_transaction_session_timeout"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.clinicogenomics.name
  value               = "21600000"
  depends_on = [
    azurerm_postgresql_server.clinicogenomics
  ]
}

resource "azurerm_postgresql_virtual_network_rule" "pgruleprimary" {
  name                = format("pgprimary-%s", var.environment)
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.clinicogenomics.name
  subnet_id           = azurerm_subnet.clinicogenomics_subnet.id
  depends_on = [
    azurerm_postgresql_server.clinicogenomics,
    azurerm_subnet.clinicogenomics_subnet
  ]
}


resource "azurerm_postgresql_virtual_network_rule" "pgrulesecondary" {
  name                = format("pgsecondary-%s-2", var.environment)
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.clinicogenomics.name
  subnet_id           = azurerm_subnet.clinicogenomics_subnet2.id
  depends_on = [
    azurerm_postgresql_server.clinicogenomics,
    azurerm_subnet.clinicogenomics_subnet2
  ]
}

resource "azurerm_postgresql_database" "cdm_db" {
  name                = "cdm_db"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.clinicogenomics.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}


# Generate passwords that the user can choose to use
module "cdm_password" {
  source = "./modules/password_module"
}

module "df_password" {
  source = "./modules/password_module"
}

module "postgres_password" {
  source = "./modules/password_module"
}

output "postgres-user-permissions" {
  value = <<EOT

#Connect to your postgres database using psql

 $  psql "host=${azurerm_postgresql_server.clinicogenomics.fqdn} \
          port=5432 dbname=postgres \
          user=postgres@${azurerm_postgresql_server.clinicogenomics.fqdn}.postgres.database.azure.com \
          password=${module.postgres_password.password} \
          sslmode=require"

#These queries create the users and assign permissions to teh databases that were created by terraform.

CREATE USER cdm_user with  createdb login password '${module.cdm_password.password}';
CREATE USER datafactory_user with login password '${module.df_password.password}';

grant all on database cdm_db to cdm_user;
EOT

}
