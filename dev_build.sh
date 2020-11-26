#!/usr/bin/env bash

# a build file to be used for builidng local release
# exit on error
set -o errexit

# get the dependncies
mix deps.get --only prod
MIX_ENV=prod mix compile

# add the required environments
source .env

# remove the build
rm -rf "_build"

MIX_ENV=prod mix release --overwrite