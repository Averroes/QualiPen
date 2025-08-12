#!/bin/bash
echo "Launching OWASP ZAP..."
# Create persistent volume for ZAP if it doesn't exist
docker volume create --name=zap-data > /dev/null
docker run -it --rm \
  --name zap-gui \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v \"zap-data:/root/.ZAP\" \
  -v \"$(pwd)/data:/root/data\" \
  tools-team \
  zaproxy