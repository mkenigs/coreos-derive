#!/usr/bin/env bash

set -euxo pipefail

source ./variables.sh

FCOS="$PWD/fcos"
RPM_OSTREE_URL=https://jenkins-coreos-ci.apps.ocp.ci.centos.org/job/github-ci/job/coreos/job/rpm-ostree/job/main/1/artifact/rpm-ostree-2022.1.67.ge0636655-1.fc35.x86_64.rpm
RPM_OSTREE_LIBS_URL=https://jenkins-coreos-ci.apps.ocp.ci.centos.org/job/github-ci/job/coreos/job/rpm-ostree/job/main/1/artifact/rpm-ostree-libs-2022.1.67.ge0636655-1.fc35.x86_64.rpm

cosa() {
   set +eu
   env | grep COREOS_ASSEMBLER
   local -r COREOS_ASSEMBLER_CONTAINER_LATEST="quay.io/coreos-assembler/coreos-assembler:latest"
   if [[ -z ${COREOS_ASSEMBLER_CONTAINER} ]] && $(podman image exists ${COREOS_ASSEMBLER_CONTAINER_LATEST}); then
       local -r cosa_build_date_str="$(podman inspect -f "{{.Created}}" ${COREOS_ASSEMBLER_CONTAINER_LATEST} | awk '{print $1}')"
       local -r cosa_build_date="$(date -d ${cosa_build_date_str} +%s)"
       if [[ $(date +%s) -ge $((cosa_build_date + 60*60*24*7)) ]] ; then
         echo -e "\e[0;33m----" >&2
         echo "The COSA container image is more that a week old and likely outdated." >&2
         echo "You should pull the latest version with:" >&2
         echo "podman pull ${COREOS_ASSEMBLER_CONTAINER_LATEST}" >&2
         echo -e "----\e[0m" >&2
         sleep 10
       fi
   fi
   podman run --rm -ti --security-opt label=disable --privileged                                    \
              --uidmap=1000:0:1 --uidmap=0:1:1000 --uidmap 1001:1001:64536                          \
              -v ${PWD}:/srv/ --device /dev/kvm --device /dev/fuse                                  \
              --tmpfs /tmp -v /var/tmp:/var/tmp --name cosa                                         \
              ${COREOS_ASSEMBLER_CONFIG_GIT:+-v $COREOS_ASSEMBLER_CONFIG_GIT:/srv/src/config/:ro}   \
              ${COREOS_ASSEMBLER_GIT:+-v $COREOS_ASSEMBLER_GIT/src/:/usr/lib/coreos-assembler/:ro}  \
              ${COREOS_ASSEMBLER_CONTAINER_RUNTIME_ARGS}                                            \
              ${COREOS_ASSEMBLER_CONTAINER:-$COREOS_ASSEMBLER_CONTAINER_LATEST} "$@"
   rc=$?; set +x; return $rc
   set -eu
}

ensure_fcos() {

  if skopeo inspect "$FCOS_IMAGE" &> /dev/null; then
    return
  fi

  mkdir "$FCOS"
  pushd "$FCOS"
    cosa init https://github.com/coreos/fedora-coreos-config
    cosa fetch
  popd
  
  # build custom Ignition and Butane

  if ! skopeo inspect containers-storage:localhost/"$BUILDER" &> /dev/null; then
    buildah from --name "$BUILDER" registry.fedoraproject.org/fedora-toolbox
    buildah run "$BUILDER" dnf install -y make libblkid-devel go
    buildah commit "$BUILDER" "$BUILDER"
  fi

  git clone -b pr/apply --single-branch https://github.com/jlebon/ignition
  #--security-opt label=disable is necessary if selinux is enabled, otherwise don't have perms to the directory
  podman run -v "$PWD":/coreos-derive --security-opt label=disable localhost/"$BUILDER" make -C /coreos-derive/ignition install DESTDIR="/coreos-derive/fcos/overrides/rootfs"

  git clone --single-branch https://github.com/coreos/butane
  podman run -v "$PWD":/coreos-derive --security-opt label=disable localhost/"$BUILDER" bash -c "cd /coreos-derive/butane && ./build && cp ./bin/amd64/butane ../fcos/overrides/rootfs/usr/bin/butane"


  # override rpm-ostree
  curl --create-dirs  --output-dir "$FCOS/overrides/rpm" -O "$RPM_OSTREE_URL"
  curl --output-dir "$FCOS/overrides/rpm" -O "$RPM_OSTREE_LIBS_URL"
  
  pushd "$FCOS"
    cosa build
  popd

  skopeo copy oci-archive:$(ls "$FCOS"/builds/latest/x86_64/*.ociarchive) "$FCOS_IMAGE"
}