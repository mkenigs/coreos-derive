#!/usr/bin/env bash

set -euxo pipefail

source ./variables.sh
IGNITION=/usr/lib/dracut/modules.d/30ignition/ignition
WORKING_CONTAINER=coreos-derive
TEST_IGN_PATH="/etc/test.ign"

source ./build-fcos.sh
ensure_fcos

buildah rm "$WORKING_CONTAINER"
buildah from --name "$WORKING_CONTAINER" "$FCOS_IMAGE"
buildah copy "$WORKING_CONTAINER" test.ign "$TEST_IGN_PATH"
# container=1: tell ignition-liveapply we in a container so it doesn't fail
buildah run --env container=1 "$WORKING_CONTAINER" -- sh -c "exec -a ignition-liveapply $IGNITION $TEST_IGN_PATH"
buildah commit "$WORKING_CONTAINER" layer1