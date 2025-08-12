#!/bin/bash
echo "Launching Burp Suite Pro..."
# Check if the Burp volume exists, otherwise display help message.
docker volume inspect burp-data > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "ERROR: The 'burp-data' volume was not found."
    echo "Please run the one-time Burp installation before launching this script."
    exit 1
fi

docker run -it --rm \
  --name burp-pro \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v \"burp-data:/root/burp\" \
  -v \"$(pwd)/data:/root/data\" \
  tools-team \
  /root/burp/BurpSuitePro