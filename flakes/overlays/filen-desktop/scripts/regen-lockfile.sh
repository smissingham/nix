#!/bin/bash

TEMP_REPO_PATH="./tmp"

# Run this script from the same folder containing package.nix
echo "Deleting local package-lock.json"
rm -f package-lock.json

echo "Cloning temp github repo locally"
rm -rf "$TEMP_REPO_PATH"
git clone git@github.com:FilenCloudDienste/filen-desktop --depth 1 "$TEMP_REPO_PATH"

echo "Deleting repo committed lock file"
rm -rf "$TEMP_REPO_PATH"/package-lock.json

echo "Regenerating package lockfile"
pushd "$TEMP_REPO_PATH" || exit
npm install --package-lock-only
cp package-lock.json ../
popd || exit

echo "Cleaning up temp rempo"
rm -rf "$TEMP_REPO_PATH"
