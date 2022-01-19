# hackweek coreos-derive prototype
1. ` derive_pipeline.sh` and is the only script you (should) need to run directly to make it work
2. First it uses `butane` to convert `import_butane.bu` to `test.ign`, which contains an `/etc/rpm-ostree-layer.yaml` treefile
3. Then (if necessary) from `build-fcos.sh`:
    - builds ignition binries
    - retrieves rpm-ostree packages
    - builds an fcos image containing those overrides
4. Then in `coreos-derive.sh`: 
    - Uses `buildah` with our fcos image as a base: 
    - Applies the ignition files to the container using `ignition-liveapply`
    - Applies the packages contained in the /etc/rpm-ostree-layer.yaml that was applied from the ignition using `rpmostree compose container`
5. Which results in two derived images
    - `localhost/with-ignition` (fcos image w/ just ignition)
    - `localhost/with-rpms`    (fcos image w/ ignition + rpms)    


