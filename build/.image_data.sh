#!/usr/bin/env bash

BROWSER_IMAGE_PATTERN="smartassert/%s-runner"
CHROME_IMAGE_REPOSITORY=$(printf ${BROWSER_IMAGE_PATTERN} "chrome")

DEFAULT_TAG="${TRAVIS_BRANCH:-master}"
TAG="${1:-${DEFAULT_TAG}}"

CHROME_IMAGE_NAME=${CHROME_IMAGE_REPOSITORY}:${TAG}

echo "Chrome image name: "${CHROME_IMAGE_NAME}
