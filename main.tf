locals {
  specific_tags = {
    "description" = var.description
  }
  account_tier             = (var.account_kind == "FileStorage" ? "Premium" : split("_", var.skuname)[0])
  account_replication_type = (local.account_tier == "Premium" ? "LRS" : split("_", var.skuname)[1])
  location                 = coalesce(var.custom_location, data.azurerm_resource_group.parent_group.location)
  parent_tags              = { for n, v in data.azurerm_resource_group.parent_group.tags : n => v if n != "description" }
  resource_name            = coalesce(var.custom_name, azurecaf_name.self.result)
  tags                     = { for n, v in merge(local.parent_tags, local.specific_tags, var.custom_tags) : n => v if v != "" }
}

data "azurerm_resource_group" "parent_group" {
  name = var.resource_group_name
}

resource "azurecaf_name" "self" {
  name          = format("%02d", var.instance_index)
  resource_type = "azurerm_storage_account"
  prefixes      = var.caf_prefixes
  suffixes      = []
  use_slug      = true
  clean_input   = true
  random_length = 5
  separator     = "-"
}

resource "azurerm_storage_account" "self" {
  name                            = local.resource_name
  resource_group_name             = data.azurerm_resource_group.parent_group.name
  location                        = local.location
  account_kind                    = var.account_kind
  account_tier                    = local.account_tier
  account_replication_type        = local.account_replication_type
  enable_https_traffic_only       = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = var.enable_advanced_threat_protection == true ? true : false
  tags                            = local.tags
  shared_access_key_enabled       = var.shared_access_key_enabled
  is_hns_enabled                  = var.is_hns_enabled

  dynamic "static_website" {
    for_each = var.static_website != null ? ["true"] : []
    content {
      index_document     = var.static_website.index_document
      error_404_document = var.static_website.error_404_document
    }
  }

  dynamic "blob_properties" {
    for_each = var.is_hns_enabled ? [] : ["true"]
    content {
      delete_retention_policy {
        days = var.blob_soft_delete_retention_days
      }
      container_delete_retention_policy {
        days = var.container_soft_delete_retention_days
      }
      versioning_enabled       = var.enable_versioning
      last_access_time_enabled = var.last_access_time_enabled
      change_feed_enabled      = var.change_feed_enabled
    }
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "network_rules" {
    for_each = var.network_rules != null ? ["true"] : []
    content {
      default_action             = "Deny"
      bypass                     = var.network_rules.bypass
      ip_rules                   = var.network_rules.ip_rules
      virtual_network_subnet_ids = var.network_rules.subnet_ids
    }
  }
}


resource "azurerm_advanced_threat_protection" "atp" {
  target_resource_id = azurerm_storage_account.self.id
  enabled            = var.enable_advanced_threat_protection
}

resource "azurerm_storage_container" "container" {
  count                 = length(var.containers_list)
  name                  = var.containers_list[count.index].name
  storage_account_name  = azurerm_storage_account.self.name
  container_access_type = var.containers_list[count.index].access_type
}

resource "azurerm_storage_share" "fileshare" {
  count                = length(var.file_shares)
  name                 = var.file_shares[count.index].name
  storage_account_name = azurerm_storage_account.self.name
  quota                = var.file_shares[count.index].quota
}

resource "azurerm_storage_table" "tables" {
  count                = length(var.tables)
  name                 = var.tables[count.index]
  storage_account_name = azurerm_storage_account.self.name
}

resource "azurerm_storage_queue" "queues" {
  count                = length(var.queues)
  name                 = var.queues[count.index]
  storage_account_name = azurerm_storage_account.self.name
}
