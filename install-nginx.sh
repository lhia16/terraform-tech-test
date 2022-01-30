#!/bin/bash
sudo yum -y install nginx
sudo systemctl enable nginx
sudo systemctl start nginx