# Copyright (C) 2020 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Image update tools"
DESCRIPTION = "Package group for updatable image"
HOMEPAGE = "https://github.com/rehsack/"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = "${PN}-base ${PN}-fetcher"

OVERLAY_RDEPENDS = "${@bb.utils.contains('WANTED_ROOT_DEV', 'nfs', '', 'initoverlay-${WANTED_ROOT_DEV}', d) }"

RDEPENDS_${PN}-base = "\
	procps \
	boot-fsck \
	${OVERLAY_RDEPENDS} \
	util-linux-mount \
	prd-flash-${WANTED_ROOT_DEV} \
	udev-extraconf-mount-blacklist-${WANTED_ROOT_DEV} \
"

RDEPENDS_${PN}-fetcher = "\
	${PN}-base \
	system-image-update \
	system-image-update-webui \
"
