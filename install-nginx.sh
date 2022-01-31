#!/bin/bash
sudo amazon-linux-extras install nginx1
echo "Hello AND Digital, welcome to Lhias Tech Test" > /usr/share/nginx/html/index.html
sudo systemctl enable nginx
sudo systemctl start nginx