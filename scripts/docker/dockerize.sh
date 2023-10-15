#!/bin/bash

git submodule update --init

echo
docker build . -f docker/Dockerfile --tag $TAG
docker push $TAG
