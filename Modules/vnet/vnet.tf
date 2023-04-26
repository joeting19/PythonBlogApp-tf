

# Create a resource group
resource "azurerm_resource_group" "pyblog" {
  name     = var.resourcegroup
  location = var.region
}

# Create a virtual network
resource "azurerm_virtual_network" "example" {
  name                = "pyblog-vnet"
  address_space       = [var.vnetcidr]
  location            = azurerm_resource_group.pyblog.location
  resource_group_name = azurerm_resource_group.pyblog.name
}

# # Create a subnet
# resource "azurerm_subnet" "pubsubnet" {
#   name                 = "public-subnet"
#   address_prefixes     = [var.subncidrs]
#   resource_group_name  = azurerm_resource_group.pyblog.name
#   virtual_network_name = azurerm_virtual_network.example.name
# }

# Create subnets
resource "azurerm_subnet" "subnets" {
  count                = 3
  name                 = count.index == 0 ? "backend-subnet" : count.index == 1 ? "database-subnet" : "public-subnet"
  resource_group_name  = azurerm_resource_group.pyblog.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = count.index == 0 ? [var.subncidrs[0]] : count.index == 1 ? [var.subncidrs[1]] : [var.subncidrs[2]]
}

#for convenience, i add public IP for all VMs
resource "azurerm_public_ip" "publicip" {
  count               = 5
  name                = "${var.vmnames[count.index]}-publicip"
  location            = var.region
  resource_group_name = azurerm_resource_group.pyblog.name
  allocation_method   = "Static"
}

#this code is for when i want to switch to private ip only for blog and db
# resource "azurerm_public_ip" "publicip" {
#   count               = 3
#   name                = "${var.vmnames[count.index+2]}-publicip"
#   location            = var.region
#   resource_group_name = azurerm_resource_group.pyblog.name
#   allocation_method   = "Static"
# }


# Create a network security group
resource "azurerm_network_security_group" "blognsg" {
  name                = "blog-nsg"
  location            = azurerm_resource_group.pyblog.location
  resource_group_name = azurerm_resource_group.pyblog.name

  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#Create a network interface
resource "azurerm_network_interface" "blognic" {
  count               = 5
  name                = "${var.vmnames[count.index]}-nic"

  location            = azurerm_resource_group.pyblog.location
  resource_group_name = azurerm_resource_group.pyblog.name

  ip_configuration {
    name                          = "${var.vmnames[count.index]}-ipconfig"
    subnet_id                     = count.index == 0 ? azurerm_subnet.subnets[0].id : count.index == 1 ?  azurerm_subnet.subnets[1].id : count.index > 1 ? azurerm_subnet.subnets[2].id : null
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip[count.index].id
  }
}

#this code is to make it more secure, no public ip for nics

# resource "azurerm_network_interface" "blognic" {
#   count               = 5
#   name                = "${var.vmnames[count.index]}-nic"
#   location            = azurerm_resource_group.pyblog.location
#   resource_group_name = azurerm_resource_group.pyblog.name

#   ip_configuration {
#     name                          = "${var.vmnames[count.index]}-ipconfig"
#     subnet_id                     = count.index == 0 ? azurerm_subnet.subnets[0].id : count.index == 1 ?  azurerm_subnet.subnets[1].id : count.index > 1 ? azurerm_subnet.subnets[2].id : null
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = count.index >= 2 ? azurerm_public_ip.publicip[count.index - 2].id : null
#   }
# }

