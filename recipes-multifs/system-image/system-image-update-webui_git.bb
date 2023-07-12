DESCRIPTION = "System::Image::Update::WebUI helps keeping up-to-date on embedded systems"

SECTION = "libs"
LICENSE = "Artistic-2.0"
PR = "r0"

MAINTAINER=	"Jens Rehsack <sno@netbsd.org>"
HOMEPAGE=	"https://github.com/rehsack/System-Image-Update-WebUI"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Artistic-2.0;md5=8bbc66f0ba93cec26ef526117e280266 \
"

SRCREV="1ed79d5075037b3fdc26fab02ebd1f318b9c8121"

SRC_URI = "git://github.com/rehsack/System-Image-Update-WebUI.git \
           file://webui-run \
	   file://system-image-update-web.json \
	   file://system-image-update-web.conf \
"

inherit supervised record-installed-query system-image-update

PACKAGECONFIG ??= ""

PROVIDES:append = " ${PN}-nginx-proxy"
PACKAGES =+ "${PN}-nginx-proxy"
PACKAGECONFIG[nginx-proxy] = ""

RDEPENDS_${PN} += "system-image-update"

RDEPENDS_${PN} += "dancer2-perl"
RDEPENDS_${PN} += "datetime-format-duration-perl"
RDEPENDS_${PN} += "encode-perl"
RDEPENDS_${PN} += "file-find-rule-perl"
RDEPENDS_${PN} += "file-slurper-perl"
RDEPENDS_${PN} += "file-touch-perl"
RDEPENDS_${PN} += "hash-merge-perl"
RDEPENDS_${PN} += "hash-moreutils-perl"
RDEPENDS_${PN} += "http-tiny-perl"
RDEPENDS_${PN} += "json-perl"
RDEPENDS_${PN} += "module-pluggable-perl"
RDEPENDS_${PN} += "moo-perl"
RDEPENDS_${PN} += "namespace-clean-perl"
RDEPENDS_${PN} += "net-async-http-server-perl"
RDEPENDS_${PN} += "net-dns-perl"
RDEPENDS_${PN} += "netaddr-ip-perl"
RDEPENDS_${PN} += "perl-modules"
RDEPENDS_${PN} += "plack-perl"
RDEPENDS_${PN} += "scalar-list-utils-perl"
RDEPENDS_${PN} += "template-toolkit-perl"
RDEPENDS_${PN} += "unix-statgrab-perl"
RDEPENDS_${PN} += "yaml-libyaml-perl"

RDEPENDS_${PN} += "${@bb.utils.contains("PACKAGECONFIG", 'nginx-proxy', ' ${PN}-nginx-proxy ', '', d )}"

RDEPENDS_${PN}-dev += "devel-cycle-perl"
RDEPENDS_${PN}-dev += "devel-leak-object-perl"
RDEPENDS_${PN}-dev += "devel-stacktrace-perl"
RDEPENDS_${PN}-dev += "test-leaktrace-perl"
RDEPENDS_${PN}-dev += "test-memory-cycle-perl"

RDEPENDS_${PN}-nginx-proxy += "nginx"

SERVICE_NAME = "sysimg-update-webui"
SERVICE_RUN_SCRIPT_NAME_${PN} = "webui-run"
SERVICE_LOG_SCRIPT_NAME = "log.run"

SYSUPDATE_WEBUI_BASE ?= "/opt/${DISTRO}/${SERVICE_NAME}"

do_compile() {
	set -x
	sed -i -e "s,@SERVICE_NAME[@],${SERVICE_NAME},g" -e "s,@SYSUPDATE_WEBUI_BASE[@],${SYSUPDATE_WEBUI_BASE},g" \
	    -e "s,@SYSTEM_IMAGE_UPDATE_STATE_DIR[@],${SYSTEM_IMAGE_UPDATE_STATE_DIR},g" \
	    -e "s,@RECORD_INSTALLED_DEST[@],${RECORD_INSTALLED_DEST},g" \
	    ${WORKDIR}/webui-run
}

do_install() {
	set -x

	install -d -m 755 ${D}${sysconfdir}
	install -m 0644 ${WORKDIR}/system-image-update-web.json ${D}${sysconfdir}

	# create directory for source
	install -d ${D}${SYSUPDATE_WEBUI_BASE}

	# copy source
	(cd ${WORKDIR}/git && tar cf - bin config.yml environments lib public t views) | (cd ${D}${SYSUPDATE_WEBUI_BASE} && tar xf -)
	chown -R root:root ${D}${SYSUPDATE_WEBUI_BASE}

	install -d ${D}${sysconfdir}/nginx/conf.d/
	install -m 0644 ${WORKDIR}/system-image-update-web.conf ${D}${sysconfdir}/nginx/conf.d/
}

FILES_${PN}-nginx-proxy = "${sysconfdir}/nginx/conf.d/"
FILES_${PN}-dev += "${SYSUPDATE_WEBUI_BASE}/t"
FILES_${PN} += "${SYSUPDATE_WEBUI_BASE}"
FILES_${PN} += "${sysconfdir}"

BBCLASSEXTEND = "native"
