DESCRIPTION = "bkeymaps and initscript"

HOMEPAGE = "http://dev.alpinelinux.org/bkeymaps"
LICENSE = "GPL-1.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-1.0;md5=e9e36a9de734199567a4d769498f743d"

PV = "1.13"

inherit update-rc.d

SRC_URI = "http://dev.alpinelinux.org/bkeymaps/bkeymaps-${PV}.tar.gz \
           file://bkeymap.sh"

SRC_URI[md5sum] = "a68058ab4a81cf9a8dcbaaa7a5df5b11"
SRC_URI[sha256sum] = "59d41ddb0c7a92d8ac155a82ed2875b7880c8957ea4308afa633c8b81e5b8887"

KEYMAPS_DEST_PREFIX = "/usr/share/bkeymaps"

do_compile() {
	rm -f ${S}/Makefile
}

do_install() {
	install -d ${D}${sysconfdir}/init.d
	install -m 0755 ${WORKDIR}/bkeymap.sh ${D}${sysconfdir}/init.d/bkeymap

	install -d ${D}${KEYMAPS_DEST_PREFIX}
	cp -r ${S}/bkeymaps/* ${D}${KEYMAPS_DEST_PREFIX}
}

INITSCRIPT_NAME = "bkeymap"
INITSCRIPT_PARAMS = "start 53 S ."
