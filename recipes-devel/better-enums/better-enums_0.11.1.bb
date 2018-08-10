# Copyright (C) 2018 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "C++ compile-time enum to string, iteration, in a single header file"
HOMEPAGE = "http://aantron.github.io/better-enums/"
LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/BSD-2-Clause;md5=8bef8e6712b1be5aa76af1ebde9d6378"
SECTION = "libs"

SRCREV = "2d6b337419e64b5b03c81e9aa39ee7b1a1d2cb36"
SRC_URI = "git://github.com/aantron/better-enums.git"

S = "${WORKDIR}/git"

do_install() {
    install -d ${D}/${includedir}/better-enums
    install -m 0644 ${S}/enum.h ${D}/${includedir}/better-enums
}
