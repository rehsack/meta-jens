DESCRIPTION = "System::Image::Update helps managing updates of OS images \
in embedded systems"

SECTION = "libs"
LICENSE = "Artistic-1.0 | GPL-2.0"
PR = "r0"

MAINTAINER=	"HP2 Dev Team <verteiler.hp2dev.team@rademacher.de>"
HOMEPAGE=	"https://github.com/rehsack/System-Image-Update"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Artistic-1.0;md5=cda03bbdc3c1951996392b872397b798 \
file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "git://github.com/rehsack/System-Image-Update.git;rev=57b109846393c03feb71b5d0edfd48742aafbb1f \
           file://run \
	   file://sysimg_update.json \
	   file://system-image-update-logrotate.conf \
"

RDEPENDS_${PN} += "archive-peek-libarchive-perl"
RDEPENDS_${PN} += "crypt-ripemd160-perl"
RDEPENDS_${PN} += "datetime-format-strptime-perl"
RDEPENDS_${PN} += "log-any-adapter-dispatch-perl"
RDEPENDS_${PN} += "encode-perl"
RDEPENDS_${PN} += "experimental-perl"
RDEPENDS_${PN} += "file-configdir-system-image-update-perl"
RDEPENDS_${PN} += "file-slurp-tiny-perl"
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

inherit cpan supervised

do_configure_append() {
    oe_runmake manifest
}

do_compile_append() {
	sed -i -e "s/@MACHINE[@]/${MACHINE}/g" ${WORKDIR}/sysimg_update.json
}

SERVICE_NAME = "sysimg_update"
SERVICE_LOG_SCRIPT_NAME = "log.run"

do_install_append() {
    install -d -m 755 ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/sysimg_update.json ${D}${sysconfdir}

    install -m 755 -d ${D}${sysconfdir}/logrotate.d
    install -m 644 ${WORKDIR}/system-image-update-logrotate.conf ${D}${sysconfdir}/logrotate.d/system-image-update
}

FILES_${PN} += "${sysconfdir}"

BBCLASSEXTEND = "native"
