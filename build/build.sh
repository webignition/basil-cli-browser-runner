#!/usr/bin/env bash

CURRENT_DIRECTORY="$(dirname "$0")"
source ${CURRENT_DIRECTORY}/.image_data.sh

for IMAGE_NAME in "${IMAGE_NAMES[@]}"; do
  echo "Building "${IMAGE_NAME}

  BROWSER=$(echo ${IMAGE_NAME} | cut -d '/' -f 2 | cut -d '-' -f 1)
  docker build -f ${BROWSER}.Dockerfile -t ${IMAGE_NAME} .
done
