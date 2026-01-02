#!/usr/bin/env bash

set -e

echo "Installing dependencies..."
bundle install --without development test

echo "Precompiling assets..."
bin/rails assets:precompile

echo "Build complete!"