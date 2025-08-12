#!/bin/bash
echo "Initializing QualiPen setup..."

# Update and install git if needed
sudo apt-get update
sudo apt-get install -y git

# Clone the repository (if not already done)
if [ ! -d "$HOME/QualiPen" ]; then
  git clone https://github.com/Averroes/QualiPen.git "$HOME/QualiPen"
fi

cd "$HOME/QualiPen"

# Create data and burp_installer directories if missing
mkdir -p data burp_installer

echo "Setup completed. Please see setup.md for next steps."