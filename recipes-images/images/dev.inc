# Copyright (C) 2015-2018 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

EXTRA_IMAGE_FEATURES_dev = "tools-debug \
    tools-profile \
    tools-sdk \
    dbg-pkgs \
    dev-pkgs \
"

DEV_INSTALL = "\
	ltrace \
	systemtap \
	systemtap-uprobes \
	git \
	git-perltools \
	subversion \
	valgrind \
	"

inherit rootdev-check

CONFLICT_ROOT_DEVS = "${INTERNAL_ROOT_DEV} nfs"
