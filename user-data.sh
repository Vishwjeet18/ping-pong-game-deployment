#!/bin/bash
# Update and install dependencies
yum update -y
yum install -y httpd git

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Set permissions for web root
usermod -a -G apache ec2-user
chmod 775 /var/www/html
chown -R ec2-user:apache /var/www/html

# Deploy Pong Game
cd /var/www/html
rm -rf /var/www/html/*
git clone https://github.com/atulkamble/pong-game.git
shopt -s dotglob
mv pong-game/* .
shopt -u dotglob
rm -rf pong-game

# Restart Apache
systemctl restart httpd
