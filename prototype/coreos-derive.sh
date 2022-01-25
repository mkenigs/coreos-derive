#!/usr/bin/env bash

set -euxo pipefail

source ./variables.sh
IGNITION=/usr/lib/dracut/modules.d/30ignition/ignition
WORKING_CONTAINER=coreos-derive
IGN_PATH="/etc/$TRANSPILED_IGN"

buildah from --name "$WORKING_CONTAINER" "$VERSIONED_FCOS_IMAGE"
buildah copy "$WORKING_CONTAINER" "$TRANSPILED_IGN" "$IGN_PATH"
# container=1: tell ignition-liveapply we in a container so it doesn't fail
buildah run --env container=1 "$WORKING_CONTAINER" -- sh -c "exec -a ignition-liveapply $IGNITION $IGN_PATH"
buildah commit "$WORKING_CONTAINER" with-ignition

buildah run "$WORKING_CONTAINER" rpm-ostree ex rebuild
buildah commit "$WORKING_CONTAINER" with-rpms