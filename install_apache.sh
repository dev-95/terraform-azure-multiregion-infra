#!/bin/bash
# Update and install Apache
sudo apt-get update -y
sudo apt-get install apache2 -y

# Start and enable the service
sudo systemctl start apache2
sudo systemctl enable apache2

# Create a custom landing page for your screenshot
echo "<h1>Devesh's Apache Server - Task 5 Complete!</h1>" | sudo tee /var/www/html/index.html