#!/bin/bash

if grep -q "DevOps CI/CD Demo Application" index.html; then
    echo "Test passed: Application title found."
    exit 0
else
    echo "Test failed: Application title not found."
    exit 1
fi
