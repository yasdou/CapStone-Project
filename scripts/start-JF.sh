#!/bin/bash

sudo yum update -y

# install ssm agent
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl start amazon-ssm-agent

# Install nginx
sudo amazon-linux-extras install nginx1 -y

# Create nginx server block for Jellyfin
sudo mkdir /etc/nginx/sites-available
sudo cat <<EOF > /etc/nginx/sites-available/jellyfin.conf
server {
    listen 80;
    server_name ec2; # replace with your domain name

    location / {
        proxy_pass http://localhost:8096;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto http;
        proxy_redirect off;
    }

    location /healthcheck.html {
        root /var/www/html; # replace with the directory where healthcheck.html is located
    }
}
EOF

sudo mkdir /var/www /var/www/html/
sudo cat <<EOF > /var/www/html/healthcheck.html
<!DOCTYPE html>
<html>
  <head>
    <title>Health Check</title>
  </head>
  <body>
    <p>OK</p>
  </body>
</html>
EOF

# Enable the new nginx server blocks
sudo mkdir /etc/nginx/sites-enabled
sudo ln -s /etc/nginx/sites-available/jellyfin.conf /etc/nginx/sites-enabled/

# Test the nginx configuration
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx


#install docker

sudo yum install docker -y
sudo yum install python3-pip -y
sudo pip3 install docker-compose
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo usermod -a -G docker ec2-user #optional: ec2-user doesn't need sudo to run docker commands

#install s3fs-fuse
sudo yum install -y gcc libstdc+-devel gcc-c+ fuse fuse-devel curl-devel libxml2-devel mailcap automake openssl-devel git gcc-c++
sudo git clone https://github.com/s3fs-fuse/s3fs-fuse
cd s3fs-fuse/
sudo ./autogen.sh
sudo ./configure --prefix=/usr --with-openssl
sudo make
sudo make install

#install plugin for s3 
docker plugin install rexray/s3fs:0.11.4 S3FS_REGION=us-west-2 S3FS_OPTIONS="allow_other,iam_role=auto,umask=000" --grant-all-permissions
#docker volume create --driver rexray/s3fs:0.11.4 

#run container
sudo docker run -d  --name jellyfin --restart=unless-stopped  -p ${container_port}:${container_port} jellyfin/jellyfin