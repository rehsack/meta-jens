# Copyright (C) 2020 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Application handling tools"
DESCRIPTION = "Package group for setapplication handling"
HOMEPAGE = "https://github.com/rehsack/"

inherit packagegroup

RDEPENDS_${PN}-devel = "\
	packagegroup-core-buildessential \
	ltrace \
	systemtap \
	systemtap-uprobes \
	git \
	git-perltools \
	subversion \
	valgrind \
"
RDEPENDS__${PN}-devel_append = "${@bb.utils.contains("MACHINE_FEATURES", "efi", "efibootmgr", "", d)}"
