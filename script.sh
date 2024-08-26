#!/bin/bash
echo "Updating system"
sudo apt update -y
sleep 5

echo "installing utilities"
sudo apt install -y zip unzip
sleep 5

echo "installing nginx web server"
sudo apt install -y nginx
sleep 5

echo "Removing sample files"
sudo rm -rf /var/www/html
sleep 5

echo "clone login app"
sudo git clone https://github.com/gr1817/login-1718.git /var/www/html
sleep 5

echo "browse the login app with server public ip"
