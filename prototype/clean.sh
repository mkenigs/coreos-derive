#!/usr/bin/env bash 
set -x  
source ./variables.sh

podman image rm localhost/fcos -f 
podman image rm localhost/"$BUILDER" -f
podman rm "$BUILDER"
rm -rf ./ignition
rm "$TRANSPILED_IGN"
buildah rm "$WORKING_CONTAINER"
buildah rm with-ignition
buildah rm with-rpms

#that cosa container writes files we can't delete otherwise
buildah unshare rm -rf ./fcos