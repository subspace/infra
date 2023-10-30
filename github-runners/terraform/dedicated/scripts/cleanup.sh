#! /bin/bash

set -eu

echo "running clean up script to destroy current deployment environment."
./config.sh remove --token ${GH_TOKEN}
sudo rm -rf /home/ubuntu/actions-runner
sudo rm -rf /home/ubuntu/_work
pkill -9 -f actions
exit 0
