# Copyright (C) 2015-2018 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

UPDATE_ESSENTIALS = "\
	attr \
	acl \
	e2fsprogs \
	e2fsprogs-tune2fs \
	ntp \
	ntpdate \
	ntp-utils \
	prd-flash-${WANTED_ROOT_DEV} \
	procps \
	tzdata \
	util-linux-mount \
	xz \
"
UPDATE_BASE_INSTALL = "\
	${UPDATE_ESSENTIALS} \
	date-set \
	dnsmasq \
	cronie \
	dosfstools \
	sudo \
	nginx \
	statgrab \
	saidar \
	crda \
	logrotate \
	boot-fsck \
	initoverlay-${WANTED_ROOT_DEV} \
	udev-extraconf-mount-blacklist-${WANTED_ROOT_DEV} \
	system-image-update \
"

UPDATE_INSTALL = "${UPDATE_BASE_INSTALL} \
	delivery-reset \
"
RECOVER_INSTALL="\
"
