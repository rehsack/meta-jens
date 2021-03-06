# Copyright (C) 2018-2020 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "GPW Perl on Embedded Workshop Image Bundle"
LICENSE = "MIT"
PR="r0"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
                    file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

IMAGE_CONTAINER_NO_DUMMY = "1"

UPDATABLE_BUNDLE_DEVELOPER_BUILD = "1"
UPDATABLE_BUNDLE_DEVELOPER_IMAGE_EXTNAME = "-dev"

PV = "${DISTRO_VERSION}"

inherit updatable-images-bundle
