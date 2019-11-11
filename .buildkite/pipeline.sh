#!/bin/bash

set -euo pipefail
shopt -s extglob

# This is the PHP version matrix we support. The keys of this array are the full (patch-level)
# version of PHP currently supported, and the values are additional tags to use: these are
# used for practices seen on the Docker Hub: we will always tag an image as "X.Y.Z" and
# "X.Y", but this array will also give other values - for example, we also tag the 5.6
# series as "5" (since it's the latest PHP 5 release).
declare -A php_versions=(
  # [PHP version]=<extra tags>
  [5.6.40]="5"
  [7.0.33]=""
  [7.1.33]=""
  [7.2.24]=""
  [7.3.11]="7 latest"
)

# XDebug sometimes drops support for EOL'ed PHP versions, so we can't use the stable
# channel for that version. That's where this array comes in. If a version isn't in here,
# then it means it's still safe to use the stable channel when building the PHP image.
declare -A xdebug_overrides=(
  # [PHP minor version]=XDebug version needed
  [5.6]=2.5.5
)

# Usage: create-step <version>
# * version is a full (patch-level) version specifier
create-step() {
  local version="$1"

  # NB. X.Y.Z ==> X.Y (creates the minor version by stripping off the patch)
  local minor="${version%.+([0-9])}"

  # Default to stable channel unless override present
  local xdebug="${xdebug_overrides[$minor]:-stable}"

  # Output the Buildkite step for building this particular version
  cat <<YAML
  - label: ":docker: :php: v$minor"
    env:
      XDEBUG_VERSION: "$xdebug"
    commands:
      - bash .buildkite/build.sh $version $minor ${php_versions[$version]}
    plugins:
      - seek-oss/aws-sm#v2.0.0:
          env:
            DOCKER_LOGIN_PASSWORD: buildkite/dockerhubid
      - docker-login#v2.0.1:
          username: f1builder
          password-env: DOCKER_LOGIN_PASSWORD
YAML
}

# For each key (i.e., PHP version), we output a Buildkite pipeline step and upload it
# via the agent.
{
  echo "steps:"
  for version in "${!php_versions[@]}"; do
    create-step "$version"
  done
} | buildkite-agent pipeline upload
