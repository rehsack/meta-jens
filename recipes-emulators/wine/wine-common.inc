# Copyright (C) 2018 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Wine (originally an acronym for \"Wine Is Not an Emulator\") \
is a compatibility layer capable of running Windows applications on several \
POSIX-compliant operating systems, such as Linux, macOS, & BSD. Instead of \
simulating internal Windows logic like a virtual machine or emulator, Wine \
translates Windows API calls into POSIX calls on-the-fly, eliminating the \
performance and memory penalties of other methods and allowing you to cleanly \
integrate Windows applications into ones desktop."
HOMEPAGE = "https://www.winehq.org"
LICENSE = "LGPL-2.1+"
SECTION = "emulators"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/LGPL-2.1;md5=1a6d268fd218675ffea8be556788b780"

FILESEXTRAPATHS_prepend := "${THISDIR}/${BP}:"

SRCREV = "wine-3.0.2"
SRC_URI = "git://source.winehq.org/git/wine.git;branch=stable \
    file://0001-acinclude.m4-avoid-removal-on-autoreconf.patch \
    file://0002-winegcc-prefer-framework-provided-tools.patch \
"

DEPENDS += " bison-native flex-native"

# --with-wine-tools=DIR
# --with-wine64=DIR


S = "${WORKDIR}/git"

inherit autotools gettext pkgconfig features_check
