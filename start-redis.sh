#!/bin/bash

docker rm -f redis
docker run -itd --name redis -p 127.0.0.1:6379:6379 redis:4
