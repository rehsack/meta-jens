#!/bin/bash

# Generate Testing Certificate
# ----------------------------
#
# The script `openssl-ca.sh` allows you to create a certificate and key that you
# can use for a test-setup of updatable-image-bundle.
#
# To generate the required files, execute
#
#   env ORG="Your organization" ./openssl-ca.sh
#
# This will generate a folder `openssl-ca/` that contains the generated openssl
# configuration file and a development certificate and key.
#
# To use them in your BSP in order to sign and verify bundles, you have to:
#
# 1) Add the directory to your BSP layer conf:
#
#    ${LAYERDIR}/conf/layer.conf:
#
#      DEV_SSL_DIR = "${LAYERDIR}/files/openssl-dev"
#
# 2) Make your bundle recipe use the generated key and certificate:
#
#    In your bundle recipe, let the variable `UPDATABLE_KEY_FILE`
#    point to these key and cert files:
#
#      UPDATABLE_KEY_FILE = "${DEV_SSL_DIR}/dev/private/development-1.key.pem"
#
# Now you are able to build and sign bundles that contain a rootfs that will
# allow flsh-device to verify the content of further bundles.

set -xe

ORG=${ORG:-"Test Org"}

# After the CRL expires, signatures cannot be verified anymore
CRL=${CRL:"-crldays 5000"}

BASE="$(pwd)/openssl"

if [ -e $BASE ]; then
    echo "$BASE already exists"
    exit 1
fi

mkdir -p $BASE/dev/private

echo "Development Signing Keys 1"
cd $BASE/dev
openssl genrsa -out $BASE/dev/private/development-1.key.pem 2048
openssl req -new -key $BASE/dev/private/development-1.key.pem -out $BASE/dev/development-1.csr.pem -batch -subj "/O=$ORG/CN=$ORG Development-1"
