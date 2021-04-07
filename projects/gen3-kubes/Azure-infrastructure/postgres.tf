resource "azurerm_postgresql_server" "g3DATA" {
  name                            = format("pg%s%s",var.environment,random_string.uid.result)
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name

  sku_name                        = "GP_Gen5_2"
  storage_mb                      = 81920
  backup_retention_days           = 7
  geo_redundant_backup_enabled    = false
  version                         = "11"
  ssl_enforcement_enabled         = false
  administrator_login             = "postgres"
  administrator_login_password    = module.postgres_password.password
  auto_grow_enabled               = true

  public_network_access_enabled    = true


  tags = merge(var.tags, local.common_tags)

}

resource "azurerm_postgresql_configuration" "g3DATA" {
    name                = "idle_in_transaction_session_timeout"
    resource_group_name = azurerm_resource_group.rg.name
    server_name         = azurerm_postgresql_server.g3DATA.name
    value               = "21600000"
      depends_on = [
    azurerm_postgresql_server.g3DATA
  ]
}

resource "azurerm_postgresql_virtual_network_rule" "pgruleprimary" {
  name                = format("pgprimary-%s%s",var.environment,random_string.uid.result)
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.g3DATA.name
  subnet_id           = azurerm_subnet.aks_subnet.id
    depends_on = [
    azurerm_postgresql_server.g3DATA,
    azurerm_subnet.aks_subnet
  ]
}


resource "azurerm_postgresql_virtual_network_rule" "pgrulesecondary" {
  name                = format("pgsecondary-%s%s-2",var.environment,random_string.uid.result)
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.g3DATA.name
  subnet_id           = azurerm_subnet.aks_subnet2.id
    depends_on = [
    azurerm_postgresql_server.g3DATA,
    azurerm_subnet.aks_subnet2
  ]
}


resource "azurerm_postgresql_database" "fence_db" {
  name                = "fence_db"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.g3DATA.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_database" "arborist_db" {
  name                = "arborist_db"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.g3DATA.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_database" "metadata_db" {
  name                = "metadata_db"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.g3DATA.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_database" "indexd_db" {
  name                = "indexd_db"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.g3DATA.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

# Generate passwords that the user can choose to use
module "arborist_password" {
  source           = "./modules/password_module"
}
module "fence_password" {
  source           = "./modules/password_module"
}
module "sheepdog_password" {
  source           = "./modules/password_module"
}
module "peregrine_password" {
  source           = "./modules/password_module"
}
module "postgres_password" {
  source           = "./modules/password_module"
}
module "indexd_password" {
  source           = "./modules/password_module"
}

module "opendistro_password" {
  source           = "./modules/password_module"
}



output "postgres-user-permissions" {
value = <<EOT

#Connect to your postgres database using psql

 $  psql "host=${azurerm_postgresql_server.g3DATA.fqdn} \
          port=5432 dbname=postgres \
          user=postgres@${azurerm_postgresql_server.g3DATA.fqdn} \
          password=${module.postgres_password.password} \
          sslmode=require"

#These queries create the users and assign permissions to teh databases that were created by terraform.

CREATE USER fence_gen3dev_user with  createdb login password '${module.fence_password.password}';
CREATE USER arborist_gen3dev_user with  createdb login password '${module.arborist_password.password}';
CREATE USER peregrine_gen3dev_user with  createdb login password '${module.peregrine_password.password}';
CREATE USER sheepdog_gen3dev_user with  createdb login password '${module.sheepdog_password.password}';
CREATE USER indexd_gen3dev_user with  createdb login password '${module.indexd_password.password}';


grant all on database fence_db to fence_gen3dev_user;
grant all on database arborist_db to arborist_gen3dev_user;
grant all on database indexd_db to indexd_gen3dev_user;
grant all on database metadata_db to sheepdog_gen3dev_user;
grant all on database metadata_db to peregrine_gen3dev_user;
grant sheepdog_gen3dev_user to peregrine_gen3dev_user ;

\c arborist_db
CREATE EXTENSION IF NOT EXISTS ltree;

EOT

}
