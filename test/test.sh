#!/usr/bin/env bash

CURRENT_DIRECTORY="$(dirname "$0")"
source ${CURRENT_DIRECTORY}/../build/.image_data.sh

TARGET_PATH="$(pwd)"/test/generated

function setup() {
  echo "Test::setup"

  docker build -f test/docker/Compiler.Dockerfile -t test-compiler-image .
  docker rm -f test-compiler-container 2> /dev/null
  docker create \
    -p 9001:8000 \
    -v "$(pwd)"/test/basil/chrome:/app/basil/chrome \
    -v "$(pwd)"/test/basil/firefox:/app/basil/firefox \
    -v "$(pwd)"/test/generated/chrome:/app/generated/chrome \
    -v "$(pwd)"/test/generated/firefox:/app/generated/firefox \
    --name test-compiler-container \
    test-compiler-image
  docker start test-compiler-container

  docker build -f test/docker/Nginx.Dockerfile -t test-nginx-image .
  docker rm -f test-nginx-container 2> /dev/null
  docker run -d --name test-nginx-container test-nginx-image

  docker network create test-network 2> /dev/null
  docker network connect test-network test-nginx-container
}

function main() {
  echo "Test::main"

  for IMAGE_NAME in "${IMAGE_NAMES[@]}"; do
    echo "Testing ${IMAGE_NAME}"

    BROWSER=$(echo ${IMAGE_NAME} | cut -d '/' -f 2 | cut -d '-' -f 1)

    COMPILER_OUTPUT=$( ( echo "./compiler --source=basil/${BROWSER} --target=generated/${BROWSER} "; echo "quit"; ) | nc localhost 9001)

    if [[ $COMPILER_OUTPUT =~ (Generated.*\.php) ]]; then
      GENERATED_TEST_FILENAME=${BASH_REMATCH}
    else
      echo "x generated filename extraction failed"

      return 2
    fi

    docker rm -f test-${BROWSER}-container 2> /dev/null
    docker create \
      -p 9002:8000 \
      -v "$(pwd)"/test/generated/${BROWSER}:/app/generated \
      --name test-${BROWSER}-container \
      ${IMAGE_NAME}
    docker start test-${BROWSER}-container

    docker network connect test-network test-${BROWSER}-container

    sleep 0.1

    RUNNER_OUTPUT=$( ( echo "./bin/runner --path=generated/${GENERATED_TEST_FILENAME}"; echo "quit"; ) | nc localhost 9002)
    docker rm -f test-${BROWSER}-container

    RUNNER_OUTPUT_EXIT_CODE=$(printf "${RUNNER_OUTPUT}" | head -1)
    if ! [[ $RUNNER_OUTPUT_EXIT_CODE =~ ^(0) ]]; then
      echo "x ./bin/runner --path=generated/${GENERATED_TEST_FILENAME} failed: ${RUNNER_OUTPUT_EXIT_CODE}"

      return ${RUNNER_OUTPUT_EXIT_CODE}
    fi

    echo "✓ ./bin/runner --path=generated/${GENERATED_TEST_FILENAME} successful"
  done

  return 0
}

function teardown() {
  echo "Test::teardown"

  rm -rf ${TARGET_PATH}/chrome/*.php
  rm -rf ${TARGET_PATH}/firefox/*.php

  docker rm -f test-compiler-container
  docker rm -f test-nginx-container

  docker network rm test-network
}

setup

main
MAIN_RETURN_VALUE=$?

teardown

exit ${MAIN_RETURN_VALUE}
