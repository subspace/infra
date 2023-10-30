#!/bin/zsh
echo "Running cleanup script macOS..."
rm -rf /Users/ec2-user/actions-runner/_work/
rm -rf /Users/ec2-user/actions-runner/_diag/
rm -rf /Users/ec2-user/Library/Keychains/build.keychain-db
rm -rf /Users/ec2-user/bin/gon
echo "Cleanup script completed."
