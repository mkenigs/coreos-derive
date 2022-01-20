# hackweek `coreos-derive` prototype
`derive_pipeline.sh` is the only script you (should) need to run directly to make it work
1. First it uses `butane` to convert `import_butane.bu` to `test.ign`, which contains an `/etc/rpm-ostree-layer.yaml` treefile
1. Then (if necessary) from `build-fcos.sh`:
    - builds ignition binaries
    - retrieves rpm-ostree packages
    - builds an fcos image containing those overrides
1. Then in `coreos-derive.sh`: 
    - Uses `buildah` with our fcos image as a base: 
    - Applies the ignition files to the container using `ignition-liveapply`
    - Applies the packages contained in the /etc/rpm-ostree-layer.yaml that was applied from the ignition using `rpmostree compose container`
1. Which results in two derived images
    - `localhost/with-ignition` (fcos image w/ just ignition)
    - `localhost/with-rpms`    (fcos image w/ ignition + rpms)    


