#!/usr/bin/env bash

# exit on error
set -o errexit

mix deps.get --only prod
MIX_ENV=prod mix compile

# remove the build
rm -rf "_build"

MIX_ENV=prod mix release --overwrite