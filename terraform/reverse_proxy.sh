#!/bin/bash

sudo apt update
sudo apt install git -y

cd /home/ubuntu

sudo apt install docker.io -y
git clone https://github.com/vreddhi/salt.git

cd salt
sudo docker build -t custom-nginx .
sudo docker run --name custom-nginx_1 -d -p 80:80 custom-nginx

