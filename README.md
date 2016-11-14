# ps-extras

Spec files and build scripts for creating RPM packages using Travis CI and deploying to packagecloud.io.

## Running Locally ##

Although this project is primarily intended to be used with TravisCI, there is a Vagrantfile provided for local testing and development.

```bash
vagrant up
vagrant ssh
cd /vagrant
./scripts/bootstrap.sh
docker run \
    --cap-add=SYS_ADMIN \
    --security-opt apparmor:unconfined \
    -e OS="el" \
    -e DIST="7" \
    -e PACKAGE="aria2" \
    --volume /tmp/rpmbuild:/rpmbuild \
    jrbing/ps-extras
```
