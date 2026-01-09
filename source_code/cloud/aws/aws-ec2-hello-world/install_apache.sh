#!/bin/bash

sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd.service
sudo systemctl enable httpd.service
echo "$(cat index.html)" > /var/www/html/index.html