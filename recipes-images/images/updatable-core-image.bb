# Copyright (C) 2018 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "GPW Perl on Embedded Workshop Core Image"
LICENSE = "MIT"
PR="r0"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
                    file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

include recipes-core/images/core-image-base.bb
include update.inc

inherit core-image distro_features_check

# Add extra image features
EXTRA_IMAGE_FEATURES += " \
    ssh-server-dropbear \
"

IMAGE_INSTALL += " \
	${CORE_IMAGE_BASE_INSTALL} \
	${UPDATE_ESSENTIALS} \
	${RECOVER_INSTALL} \
"

export IMAGE_BASENAME = "updatable-core-image"
PROVIDES = "updatable-core-image"
