#!/bin/bash

source .env

docker build --no-cache --build-arg OPENFHE_TAG=${OPENFHE_TAG} --build-arg OPENFHE_SDK_PYTHON_TAG=${OPENFHE_SDK_PYTHON_TAG} . -t ${IMAGE}:${OPENFHE_TAG}
