#!/bin/bash
echo "Launching an interactive shell in the container..."
docker run -it --rm \
  --name pen-shell \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v \"$(pwd)/data:/root/data\" \
  tools-team