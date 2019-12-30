# Copyright (C) 2018 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "GPW Perl on Embedded Workshop Minimal Updatable Dev Image"
LICENSE = "MIT"
PR="r0"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
                    file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

include recipes-core/images/core-image-base.bb
include update.inc
include dev.inc

inherit core-image features_check rootdev-check

# Add extra image features
EXTRA_IMAGE_FEATURES += " \
    nfs-server \
    ssh-server-dropbear \
    ${EXTRA_IMAGE_FEATURES_dev} \
"

IMAGE_INSTALL += " \
    ${CORE_IMAGE_BASE_INSTALL} \
    ${UPDATE_INSTALL} \
    ${DEV_INSTALL} \
"

export IMAGE_BASENAME = "updatable-app-dev-image"
PROVIDES = "updatable-app-dev-image"
