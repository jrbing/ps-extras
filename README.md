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
    -e MOCK_CONFIG=epel-7-x86_64 \
    -e MOCK_PACKAGE=aria2 \
    -v /tmp/rpmbuild:/rpmbuild \
    jrbing/ps-extras
```
