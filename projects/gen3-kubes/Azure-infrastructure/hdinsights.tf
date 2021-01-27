resource "azurerm_storage_account" "gen3hdinsightsstorage" {
  name                            = "hdinsightsstorage-${var.cluster_name}"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
}


resource "azurerm_storage_container" "gen3hdinsightcontainer" {
  name                  = "hdinsights"
  storage_account_name  = azurerm_storage_account.gen3hdinsightsstorage.name
  container_access_type = "private"
}

resource "azurerm_hdinsight_spark_cluster" "gen3spark" {
  name                          = "hdinsights-${var.cluster_name}"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  cluster_version               = "3.6"
  tier                          = "Standard"

  component_version {
    spark = "2.3"
  }

  gateway {
    enabled  = true
    username = "sparkadmin"
    password = ""
  }

  storage_account {
    storage_container_id = azurerm_storage_container.gen3hdinsightsstorage.id
    storage_account_key  = azurerm_storage_account.gen3hdinsightsstorage.primary_access_key
    is_default           = true
  }

  roles {
    head_node {
      vm_size  = "Standard_A1"                            # A1 has 1.75 GB memory, A0 has 0.75 GB mem. (both A1 A0 have 1 cpu)
      username = "acctestusrvm"                           #(required, local admin user name goes here)
      password = "AccTestvdSC4daf986!"                    #(optional, local admin password goes here)
    }

    worker_node {
      # Standard_A2 2-cpus 3.5-GB, if we need more mem we need to bump it back up to A3
      vm_size               = "Standard_A2"
      username              = "acctestusrvm"              #(required, local admin user name goes here)
      password              = "AccTestvdSC4daf986!"       #(optional, local admin password goes here) 
      target_instance_count = 3 #optional
    }

    zookeeper_node {
      vm_size  = "Medium"
      username = "acctestusrvm"
      password = "AccTestvdSC4daf986!"
    }
  }
}



The following arguments are supported:

    name - (Required) Specifies the name for this HDInsight Spark Cluster. Changing this forces a new resource to be created.

    resource_group_name - (Required) Specifies the name of the Resource Group in which this HDInsight Spark Cluster should exist. Changing this forces a new resource to be created.

    location - (Required) Specifies the Azure Region which this HDInsight Spark Cluster should exist. Changing this forces a new resource to be created.

    cluster_version - (Required) Specifies the Version of HDInsights which should be used for this Cluster. Changing this forces a new resource to be created.

    component_version - (Required) A component_version block as defined below.

    gateway - (Required) A gateway block as defined below.

    roles - (Required) A roles block as defined below.

    storage_account - (Required) One or more storage_account block as defined below.

    storage_account_gen2 - (Required) A storage_account_gen2 block as defined below.

    tier - (Required) Specifies the Tier which should be used for this HDInsight Spark Cluster. Possible values are Standard or Premium. Changing this forces a new resource to be created.

    min_tls_version - (Optional) The minimal supported TLS version. Possible values are 1.0, 1.1 or 1.2. Changing this forces a new resource to be created.

NOTE:

Starting on June 30, 2020, Azure HDInsight will enforce TLS 1.2 or later versions for all HTTPS connections. For more information, see Azure HDInsight TLS 1.2 Enforcement.

    tags - (Optional) A map of Tags which should be assigned to this HDInsight Spark Cluster.

    metastores - (Optional) A metastores block as defined below.

    monitor - (Optional) A monitor block as defined below.
