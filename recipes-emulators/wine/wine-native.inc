# Copyright (C) 2018 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

PACKAGECONFIG[win16] = "--enable-win16,--disable-win16,"
PACKAGECONFIG[win64] = "--enable-win64,--disable-win64,"

EXTRA_OECONF_append = " --without-freetype --without-x"

inherit native

require wine-common.inc
