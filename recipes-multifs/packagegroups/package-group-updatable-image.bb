# Copyright (C) 2020 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Image update tools"
DESCRIPTION = "Package group for updatable image"
HOMEPAGE = "https://github.com/rehsack/"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = "${PN}-base ${PN}-fetcher"

RDEPENDS_${PN}-base = "\
	procps \
	boot-fsck \
	initoverlay-${WANTED_ROOT_DEV} \
	util-linux-mount \
	prd-flash-${WANTED_ROOT_DEV} \
	udev-extraconf-mount-blacklist-${WANTED_ROOT_DEV} \
"

RDEPENDS_${PN}-fetcher = "\
	${PN}-base \
	system-image-update \
"
