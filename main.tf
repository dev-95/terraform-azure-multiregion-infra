locals {
  datacenters = {
    DC1 = "East US"
    DC2 = "West US"
    DC3 = "Central US"
  }
}

resource "azurerm_resource_group" "rg" {
  for_each = local.datacenters
  name     = "${each.key}-apps-rg"
  location = each.value
}


resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-dc1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg["DC1"].location
  resource_group_name = azurerm_resource_group.rg["DC1"].name
}

resource "azurerm_subnet" "subnet" {
  name                 = "internal-subnet"
  resource_group_name  = azurerm_resource_group.rg["DC1"].name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/25"]
}

resource "azurerm_public_ip" "pip" {
  name                = "vm-pip"
  location            = azurerm_resource_group.rg["DC1"].location
  resource_group_name = azurerm_resource_group.rg["DC1"].name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
  name                = "vm-nic"
  location            = azurerm_resource_group.rg["DC1"].location
  resource_group_name = azurerm_resource_group.rg["DC1"].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}


resource "azurerm_network_security_group" "nsg" {
  name                = "ssh-http-nsg"
  location            = azurerm_resource_group.rg["DC1"].location
  resource_group_name = azurerm_resource_group.rg["DC1"].name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_linux_virtual_machine" "vm" {
  name                = "ubuntu-server-vm"
  resource_group_name = azurerm_resource_group.rg["DC1"].name
  location            = azurerm_resource_group.rg["DC1"].location
  size                = "Standard_B1s"
  admin_username      = "azureadmin"
  
  # References the NIC from Task 2
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = "azureadmin"
    # Points to the public key you just generated
    public_key = file("C:\\Users\\deves\\.ssh\\id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


resource "null_resource" "install_apache" {
  # This ensures the VM and Networking are fully ready first
  depends_on = [azurerm_linux_virtual_machine.vm]

  connection {
    type        = "ssh"
    user        = "azureadmin"
    # Note: Use your PRIVATE key here (no .pub extension)
    private_key = file("C:\\Users\\deves\\.ssh\\id_rsa")
    host        = azurerm_public_ip.pip.ip_address
  }

  # Copies the local script to the VM's /tmp folder
  provisioner "file" {
    source      = "install_apache.sh"
    destination = "/tmp/install_apache.sh"
  }

  # Makes the script executable and runs it with sudo
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_apache.sh",
      "sudo /tmp/install_apache.sh"
    ]
  }
}

# This will print the IP address in your terminal so you can test it
output "apache_public_ip" {
  value = azurerm_public_ip.pip.ip_address
}