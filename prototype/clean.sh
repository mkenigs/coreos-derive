#!/usr/bin/env bash 
set -x  
source ./variables.sh

podman image rm localhost/fcos -f 
podman image rm localhost/"$BUILDER" -f
podman rm "$BUILDER"
rm -rf ./ignition

#that cosa container writes files we can't delete otherwise
buildah unshare rm -rf ./fcos