#!/usr/bin/env bash

CURRENT_DIRECTORY="$(dirname "$0")"
source ${CURRENT_DIRECTORY}/../build/.image_data.sh
source ${CURRENT_DIRECTORY}/docker_hub_login.sh

declare -a IMAGE_NAMES=(
  ${CHROME_IMAGE_NAME}
)

for IMAGE_NAME in "${IMAGE_NAMES[@]}"; do
  docker push ${IMAGE_NAME}
done
