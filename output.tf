output "storage_account_id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.self.id
}

output "storage_account_name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.self.name
}

output "storage_account_primary_location" {
  description = "The primary location of the storage account"
  value       = azurerm_storage_account.self.primary_location
}

output "storage_account_primary_web_endpoint" {
  description = "The endpoint URL for web storage in the primary location."
  value       = azurerm_storage_account.self.primary_web_endpoint
}

output "storage_account_primary_web_host" {
  description = "The hostname with port if applicable for web storage in the primary location."
  value       = azurerm_storage_account.self.primary_web_host
}

output "storage_primary_connection_string" {
  description = "The primary connection string for the storage account"
  value       = azurerm_storage_account.self.primary_connection_string
  sensitive   = true
}


output "storage_account_secondary_location" {
  description = "The secondary location of the storage account"
  value       = azurerm_storage_account.self.secondary_location
}

output "storage_account_secondary_web_endpoint" {
  description = "The endpoint URL for web storage in the secondary location."
  value       = azurerm_storage_account.self.secondary_web_endpoint
}

output "storage_account_secondary_web_host" {
  description = "The hostname with port if applicable for web storage in the secondary location."
  value       = azurerm_storage_account.self.secondary_web_host
}

output "storage_secondary_connection_string" {
  description = "The secondary connection string for the storage account"
  value       = azurerm_storage_account.self.secondary_connection_string
  sensitive   = true
}

output "storage_primary_access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.self.primary_access_key
  sensitive   = true
}

output "storage_secondary_access_key" {
  description = "The primary access key for the storage account."
  value       = azurerm_storage_account.self.secondary_access_key
  sensitive   = true
}

output "containers" {
  description = "Map of containers."
  value       = { for c in azurerm_storage_container.container : c.name => c.id }
}

output "file_shares" {
  description = "Map of Storage SMB file shares."
  value       = { for f in azurerm_storage_share.fileshare : f.name => f.id }
}

output "tables" {
  description = "Map of Storage tables."
  value       = { for t in azurerm_storage_table.tables : t.name => t.id }
}

output "queues" {
  description = "Map of Storage queues."
  value       = { for q in azurerm_storage_queue.queues : q.name => q.id }
}
