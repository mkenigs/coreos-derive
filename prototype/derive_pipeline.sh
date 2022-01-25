#!/usr/bin/env bash

set -euxo pipefail

source ./variables.sh

# not sure yet whether butane will be in the fcos image and coreos-derive, but for now just lumping it into the fcos image
podman run -v "$PWD":/coreos-derive --security-opt label=disable "$VERSIONED_FCOS_IMAGE" butane --pretty --strict /coreos-derive/input.bu -o /coreos-derive/"$TRANSPILED_IGN"
./coreos-derive.sh