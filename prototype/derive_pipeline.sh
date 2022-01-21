#!/usr/bin/env bash

set -euxo pipefail

source ./variables.sh
source ./build-fcos.sh

# not sure yet whether butane will be in the fcos image and coreos-derive, but for now just lumping it into the fcos image
ensure_fcos
podman run -v "$PWD":/coreos-derive --security-opt label=disable "$FCOS_IMAGE" butane --pretty --strict /coreos-derive/input.bu -o /coreos-derive/"$TRANSPILED_IGN"
./coreos-derive.sh