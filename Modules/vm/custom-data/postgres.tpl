#!/bin/bash
sudo apt update -y
sudo apt install docker.io -y
sudo systemctl start docker
sudo usermod -aG docker ${USER}
sudo chmod 666 /var/run/docker.sock

sudo apt install azure-cli -Y

#install az copy

# Download and extract 
wget https://aka.ms/downloadazcopy-v10-linux
tar -xvf downloadazcopy-v10-linux

# Move AzCopy
sudo rm -f /usr/bin/azcopy
sudo cp ./azcopy_linux_amd64_10.17.0/azcopy /usr/bin/
sudo chmod 755 /usr/bin/azcopy

# Clean the kitchen
rm -f downloadazcopy-v10-linux
rm -rf ./azcopy_linux_amd64_10.17.0/