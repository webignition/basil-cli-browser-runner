#!/usr/bin/env bash

CURRENT_DIRECTORY="$(dirname "$0")"
source ${CURRENT_DIRECTORY}/../build/.image_data.sh

TARGET_PATH="$(pwd)"/test/generated

function setup() {
  echo "Test::setup"

  docker build -f test/docker/Compiler.Dockerfile -t compiler-test .

  docker rm nginx-test
  docker build -f test/docker/Nginx.Dockerfile -t nginx-test .
  docker run -d --name nginx-test nginx-test

  docker network create test-network
  docker network connect test-network nginx-test
}

function main() {
  echo "Test::main"
  echo "Testing "${IMAGE_NAME}

  COMMAND="./bin/runner --path=generated"

  for IMAGE_NAME in "${IMAGE_NAMES[@]}"; do
    BROWSER=$(echo ${IMAGE_NAME} | cut -d '/' -f 2 | cut -d '-' -f 1)
    SOURCE_PATH="$(pwd)"/test/basil/${BROWSER}

    docker run \
      -v ${SOURCE_PATH}:/app/basil \
      -v ${TARGET_PATH}:/app/generated \
      -it \
      compiler-test ./compiler --source=basil --target=generated

    EXECUTABLE="${IMAGE_NAME} ${COMMAND}"

    docker run \
      -v ${TARGET_PATH}:/app/generated \
      --network=test-network \
      -it \
      ${EXECUTABLE}

    if [ ${?} != 0 ]; then
      echo "x" ${EXECUTABLE} "failed"

      return 1
    fi

    echo "✓" ${EXECUTABLE} "successful"
  done

  return 0
}

function teardown() {
  echo "Test::teardown"

  rm -rf ${TARGET_PATH}/*.php

  docker stop nginx-test
  docker network rm test-network
}

setup

main
MAIN_RETURN_VALUE=$?

teardown

exit ${MAIN_RETURN_VALUE}
