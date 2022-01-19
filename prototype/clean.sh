#!/usr/bin/env bash 
set -x  
podman image rm localhost/fcos -f 
podman image rm localhost/ignition-builder -f 
podman rm ignition-builder
rm -rf ./ignition

#that cosa container writes files we can't delete otherwise
buildah unshare rm -rf ./fcos 


