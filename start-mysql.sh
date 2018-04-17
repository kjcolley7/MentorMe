#!/bin/bash

docker rm -f mysql
docker run -itd --name mysql -p 127.0.0.1:3306:3306 -e MYSQL_ROOT_PASSWORD=changeme -e MYSQL_USER=mentor -e MYSQL_PASSWORD=changeme -e MYSQL_DATABASE=mentor mysql:5.7
