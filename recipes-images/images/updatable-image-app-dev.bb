# Copyright (C) 2018-2020 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "GPW Perl on Embedded Workshop Core Image"
LICENSE = "MIT"
PR="r0"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
                    file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit updatable-image features_check

# Add extra image features
EXTRA_IMAGE_FEATURES += " \
	tools-debug \
	tools-profile \
	tools-sdk \
	dbg-pkgs \
	dev-pkgs \
	\
	ssh-server-dropbear \
	updatable-fetcher \
	app-core \
	app-devel \
"

DEPENDS += "${@['updatable-image-core-dev', ''][d.getVar('WANTED_ROOT_DEV') == 'nfs']}"
IMAGE_FSTYPES = "wic"
