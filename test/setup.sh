#!/usr/bin/env bash

docker build -f test/docker/Compiler.Dockerfile -t compiler-test .
docker run \
  -v "$(pwd)"/test/basil:/app/basil \
  -v "$(pwd)"/test/generated:/app/generated \
  -it \
  compiler-test ./compiler --source=basil --target=generated

docker rm nginx-test
docker build -f test/docker/Nginx.Dockerfile -t nginx-test .
docker run -d --name nginx-test nginx-test

docker network create test-network
docker network connect test-network nginx-test
