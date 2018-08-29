#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# https://github.com/chef/omnibus-toolchain/issues/73
rm /opt/omnibus-toolchain/bin/tar
rm /opt/omnibus-toolchain/bin/gtar
rm /opt/omnibus-toolchain/embedded/bin/tar

apt-get update
