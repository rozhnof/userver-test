#!/bin/bash

# ssh -p 2222 template_service@IP_ADDRESS
echo ${PWD}
docker-compose down
docker-compose up -d

