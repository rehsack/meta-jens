DESCRIPTION = "System::Image::Update helps managing updates of OS images \
in embedded systems"

SECTION = "libs"
LICENSE = "Artistic-2.0"
PR = "r0"

MAINTAINER=	"Jens Rehsack <sno@netbsd.org>"
HOMEPAGE=	"https://github.com/rehsack/System-Image-Update"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Artistic-2.0;md5=8bbc66f0ba93cec26ef526117e280266 \
"
SRC_URI = "git://github.com/rehsack/System-Image-Update.git;rev=6cab03cc59412c12cacc67c3095e4e73ac791513 \
           file://run \
	   file://sysimg-update.json \
	   file://sysimg-update.properties \
	   file://system-image-update-logrotate.conf \
"

RDEPENDS_${PN} += "archive-peek-libarchive-perl"
RDEPENDS_${PN} += "class-load-perl"
RDEPENDS_${PN} += "crypt-ripemd160-perl"
RDEPENDS_${PN} += "datetime-format-strptime-perl"
RDEPENDS_${PN} += "log-any-adapter-log4cplus-perl"
RDEPENDS_${PN} += "encode-perl"
RDEPENDS_${PN} += "experimental-perl"
RDEPENDS_${PN} += "file-configdir-system-image-update-perl"
RDEPENDS_${PN} += "file-slurper-perl"
RDEPENDS_${PN} += "json-perl"
RDEPENDS_${PN} += "io-async-perl"
RDEPENDS_${PN} += "moo-perl"
RDEPENDS_${PN} += "moox-configfromfile-perl"
RDEPENDS_${PN} += "moox-log-any-perl"
RDEPENDS_${PN} += "moox-options-perl"
RDEPENDS_${PN} += "moox-role-logger-perl"
RDEPENDS_${PN} += "net-async-http-perl"
RDEPENDS_${PN} += "digest-md5-perl"
RDEPENDS_${PN} += "digest-sha-perl"
RDEPENDS_${PN} += "digest-sha3-perl"
RDEPENDS_${PN} += "perl-module-storable"
RDEPENDS_${PN} += "perl-modules"
RDEPENDS_${PN} += "system-image"
RDEPENDS_${PN} += "logrotate"
DEPENDS += "test-pod-perl"

S = "${WORKDIR}/git"

inherit cpan supervised record-installed-query

SERVICE_NAME = "sysimg-update"
SERVICE_LOG_SCRIPT_NAME = "log.run"

SYSTEM_IMAGE_UPDATE_DIR = "/data/.update"
SYSTEM_IMAGE_UPDATE_FLASH_DIR = "/data/.flashimg"

do_configure_append() {
	oe_runmake manifest
}

do_compile_append() {
	sed -i -e "s,@SERVICE_NAME[@],${SERVICE_NAME},g" -e "s/@MACHINE[@]/${MACHINE}/g" \
	    -e "s,@SYSTEM_IMAGE_UPDATE_DIR[@],${SYSTEM_IMAGE_UPDATE_DIR},g" \
	    -e "s,@SYSTEM_IMAGE_UPDATE_FLASH_DIR[@],${SYSTEM_IMAGE_UPDATE_FLASH_DIR},g" \
	    -e "s,@RECORD_INSTALLED_DEST[@],${RECORD_INSTALLED_DEST},g" \
	    ${WORKDIR}/run ${WORKDIR}/sysimg-update.json
}

do_install_append() {
    install -d -m 755 ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/sysimg-update.json ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/sysimg-update.properties ${D}${sysconfdir}

    install -m 755 -d ${D}${sysconfdir}/logrotate.d
    install -m 644 ${WORKDIR}/system-image-update-logrotate.conf ${D}${sysconfdir}/logrotate.d/system-image-update
}

FILES_${PN} += "${sysconfdir}"

BBCLASSEXTEND = "native"
