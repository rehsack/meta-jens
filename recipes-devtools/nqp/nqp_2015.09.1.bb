# Copyright (C) 2015 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

require nqp.inc

SRC_URI_append = "\
    file://enable-sysroot.patch \
    file://allow-influening.patch \
"

SRC_URI[md5sum] = "03ab29398edcfc5a0a1d8bb9494b9976"
SRC_URI[sha256sum] = "dffc1ff6f9c4a0d5d4670459ceb785765d32d2060ba896a9766451603e674560"
