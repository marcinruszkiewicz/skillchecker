#!/usr/bin/env bash
# Initial setup
mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix phx.digest
MIX_ENV=prod mix sentry.package_source_code

# Remove the existing release directory and build the release
rm -rf "_build"
MIX_ENV=prod mix release

# for auto DB migration upon deploy
MIX_ENV=prod mix ecto.migrate
