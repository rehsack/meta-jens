DESCRIPTION = "Utilities to collect and visualise system statistics"
HOMEPAGE = "http://www.i-scream.org/libstatgrab/"

LICENSE = "GPL-2.0+"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

DEPENDS = "ncurses"

PV = "0.91"

FILESEXTRAPATHS_prepend := "${THISDIR}/patches:"
PACKAGES_prepend = "statgrab statgrab-dbg saidar saidar-dbg ${PN}-mrtg "

SRCREV = "c39988855a9d1eb54adadb899b3865304da2cf84"
SRC_URI = "git://github.com/i-scream/libstatgrab.git \
           file://linux-proctbl-names-with-spaces.patch \
          "

EXTRA_OECONF = "--without-perl5 --with-mnttab=/proc/mounts"

S = "${WORKDIR}/git"

inherit autotools pkgconfig

FILES_statgrab = "${bindir}/statgrab"
FILES_statgrab-dbg = "${bindir}/.debug/statgrab"
FILES_saidar = "${bindir}/saidar"
FILES_saidar-dbg = "${bindir}/.debug/saidar"
FILES_${PN}-mrtg = "${bindir}/statgrab-make-mrtg-config ${bindir}/statgrab-make-mrtg-index"
RDEPENDS_${PN}-mrtg_append = "perl statgrab"
