#!/bin/sh

set -e

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
echo "hello world"
echo "this is a post-install script"

exit 0
