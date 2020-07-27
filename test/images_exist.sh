#!/usr/bin/env bash

CURRENT_DIRECTORY="$(dirname "$0")"
source ${CURRENT_DIRECTORY}/../build/.image_data.sh

for IMAGE_NAME in "${IMAGE_NAMES[@]}"; do
  OUTPUT=$(docker images | tail -n +2 | awk '{print $1":"$2}' | grep ${IMAGE_NAME} | wc -l)

  if [ ${OUTPUT} != "1" ]; then
    echo "x" ${IMAGE_NAME} "does not exist"
    exit 1
  fi

  echo "✓" ${IMAGE_NAME} "exists"
done
