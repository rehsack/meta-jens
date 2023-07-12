# Copyright (C) 2015 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

require rakudo-star.inc

SRC_URI_append = "\
    file://enable-sysroot.patch \
    file://rakudo-enable-sysroot.patch \
    file://rakudo-enable-staging_dir.patch \
"

SRC_URI[md5sum] = "988fdf267d76204c62c01fe7e762ac21"
SRC_URI[sha256sum] = "99b0332c4a05d444876efff58714104fc3cbf5f875174c1e410bedca03a6880d"
