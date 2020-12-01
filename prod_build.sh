#!/usr/bin/env bash

# exit on error
set -o errexit

mix deps.get --only prod
MIX_ENV=prod mix compile

# remove the build
rm -rf "_build"

MIX_ENV=prod mix release --overwrite

# reeset the db
_build/prod/rel/eworks/bin/eworks eval "Eworks.Release.EctoTasks.reset_db"
# perform migrations
_build/prod/rel/eworks/bin/eworks eval "Eworks.Release.EctoTasks.migrate"
# seed the database
_build/prod/rel/eworks/bin/eworks eval 'Eworks.Release.Seeder.seed(Eworks.Repo, "seeds.exs")'