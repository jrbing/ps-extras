[![Build Status](https://travis-ci.org/jrbing/ps-extras.svg?branch=master)](https://travis-ci.org/jrbing/ps-extras)

ps-extras
=========

Spec files and build scripts for creating RPM packages using [Travis CI][travis] and deploying to [packagecloud.io][packagecloud].


## Repository Installation ##

Run the following to import the repository. 

```bash
curl -s https://packagecloud.io/install/repositories/jrbing/ps-extras/script.rpm.sh | sudo bash
```

## Running Locally ##

Although this project is primarily intended to be used with TravisCI, there is a Vagrantfile provided for local testing and development.

```bash
vagrant up
vagrant ssh
cd /vagrant
./scripts/install.sh
export OS="el"
export DIST="7"
export PACKAGE="aria2"
./scripts/build.sh
```

[packagecloud]:https://packagecloud.io/jrbing/ps-extras "https://packagecloud.io/jrbing/ps-extras"
[travis]:https://travis-ci.org/jrbing/ps-extras "https://travis-ci.org/jrbing/ps-extras"

