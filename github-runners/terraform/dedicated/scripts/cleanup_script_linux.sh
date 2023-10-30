#!/bin/bash
echo "Running cleanup script for Linux..."
rm -rf $HOME/actions-runner/_work/*
rm -rf $HOME/actions-runner/_diag/*
echo "Cleanup script completed."
