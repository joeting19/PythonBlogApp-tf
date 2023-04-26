#!/bin/bash
sudo apt update -y
sudo apt install docker.io -y
sudo systemctl start docker
sudo usermod -aG docker ${USER}
sudo chmod 666 /var/run/docker.sock

#commands to set up docker container as reverse proxy for webapp
sudo docker run -d --name nginx-base -p 80:80 nginx:latest
docker exec -it nginx-base /bin/bash
sudo docker cp nginx-base:/etc/nginx/conf.d/default.conf ~/
sudo docker cp default.conf nginx-base:/etc/nginx/conf.d/

sudo docker exec nginx-base nginx -t
sudo docker exec nginx-base nginx -s reload

