#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# fallback in case command is accidentally run
export CONVOX_HOST="convox.invalid"

# minimum required configuration
export BUILDKITE_PLUGIN_CONVOX_BUILD_RACK="test-rack"
export BUILDKITE_PLUGIN_CONVOX_BUILD_APP="test-app"

_EXPECTED_BUILD_ARGS='build --rack="test-rack" --app="test-app"'
_OUTPUT_RELEASE_ID="BZXEXFXCXNX"
_OUTPUT_BUILD_ID="RNXNXEXSXIX"

stub_build() {
  stub convox "$1 : echo -e Build: ${_OUTPUT_BUILD_ID}$'\n'Release: ${_OUTPUT_RELEASE_ID}"
}

unstub_build() {
  unstub convox
}

subject() {
  "$PWD/hooks/command" 2>&1 >&3
}

@test "Runs the build command with minimal required configuration" {
  stub_build "${_EXPECTED_BUILD_ARGS}"

  subject

  unstub convox
}

@test "Supports a manifest path" {
  stub_build "${_EXPECTED_BUILD_ARGS} --manifest=\"convox.staging.yml\""

  BUILDKITE_PLUGIN_CONVOX_BUILD_MANIFEST="convox.staging.yml" \
    subject

  unstub convox
}

@test "Supports a build description" {
  stub_build "${_EXPECTED_BUILD_ARGS} --description=\"A build description\""

  BUILDKITE_PLUGIN_CONVOX_BUILD_DESCRIPTION="A build description" \
    subject

  unstub convox
}

@test "Supports disabling the build cache" {
  stub_build "${_EXPECTED_BUILD_ARGS} --no-cache"

  BUILDKITE_PLUGIN_CONVOX_BUILD_CACHE="false" \
    subject

  unstub convox
}

@test "Supports setting the development flag" {
  stub_build "${_EXPECTED_BUILD_ARGS} --development"

  BUILDKITE_PLUGIN_CONVOX_BUILD_DEVELOPMENT="true" \
    subject

  unstub convox
}

@test "Supports saving the Release ID to metadata" {
  stub_build "${_EXPECTED_BUILD_ARGS}"
  stub buildkite-agent "meta-data set convox-release \"${_OUTPUT_RELEASE_ID}\" : true"

  BUILDKITE_PLUGIN_CONVOX_BUILD_METADATA_RELEASE_ID="convox-release" \
    subject

  unstub convox
  unstub buildkite-agent
}

@test "Supports saving the Build ID to metadata" {
  stub_build "${_EXPECTED_BUILD_ARGS}"
  stub buildkite-agent "meta-data set convox-build-id \"${_OUTPUT_BUILD_ID}\" : true"

  BUILDKITE_PLUGIN_CONVOX_BUILD_METADATA_BUILD_ID="convox-build-id" \
    subject

  unstub convox
  unstub buildkite-agent
}
