#!/usr/bin/env bash

CURRENT_DIRECTORY="$(dirname "$0")"
source ${CURRENT_DIRECTORY}/../build/.image_data.sh

source ${CURRENT_DIRECTORY}/setup.sh

declare -a IMAGE_NAMES=(
  ${CHROME_IMAGE_NAME}
)

declare -a COMMANDS_FOR_BROWSER_IMAGES=(
  "./bin/runner --path=generated"
)

for IMAGE_NAME in "${IMAGE_NAMES[@]}"; do
  for COMMAND in "${COMMANDS_FOR_BROWSER_IMAGES[@]}"; do
    EXECUTABLE="${IMAGE_NAME} ${COMMAND}"

    docker run \
      -v "$(pwd)"/test/generated:/app/generated \
      --network=test-network \
      -it \
      ${EXECUTABLE}

    if [ ${?} != 0 ]; then
      echo "x" ${EXECUTABLE} "failed"
      source ${CURRENT_DIRECTORY}/teardown.sh

      exit 1
    fi

    echo "✓" ${EXECUTABLE} "successful"
  done
done

source ${CURRENT_DIRECTORY}/teardown.sh

exit 0
