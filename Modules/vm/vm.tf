resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create a virtual machine
resource "azurerm_linux_virtual_machine" "blogvms" {
  count               = 5
  name                = "${var.vmnames[count.index]}-vm"
  location            = var.region
  resource_group_name = var.resourcegroup
  network_interface_ids = [
    var.blog_nics[count.index],
  ]
  custom_data= filebase64("${path.module}/custom-data/pyblog.tpl")
  size           = count.index > 2 ? "Standard_B1ls" : "Standard_B1s"
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    name              = "${var.vmnames[count.index]}-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name                   = "${var.vmnames[count.index]}"
  admin_username                  = "${var.vmnames[count.index]}"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "${var.vmnames[count.index]}"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }



}

 # custom_data = base64encode(file("${path.module}/custom-data/${var.vmnames[count.index]}.sh"))
