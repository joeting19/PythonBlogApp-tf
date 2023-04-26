output "blog_nics" {
  value = azurerm_network_interface.blognic.*.id
}

output "resource_group" {
  value = azurerm_resource_group.pyblog.name
}