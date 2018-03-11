DESCRIPTION = "daemontools is a collection of tools for managing UNIX services"
HOMEPAGE = "http://cr.yp.to/daemontools.html"

LICENSE = "PD"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/PD;md5=b3597d12946881e13cb3b548d1173851"

inherit djbware update-rc.d useradd

FILESEXTRAPATHS_prepend := "${THISDIR}/${PV}-${PV}:"

S = "${WORKDIR}/admin/${PN}-${PV}"

SRC_URI = "http://cr.yp.to/daemontools/daemontools-0.76.tar.gz \
           file://error.h-use-errno.h.patch \
           file://Makefile-no-run-crosscompiled.patch \
           file://svscanboot-target-fs-adoptions.patch \
	   file://init-daemontools.sh \
	   file://sv-via-ctrl-grp.sudoers \
          "

SRC_URI[md5sum] = "1871af2453d6e464034968a0fbcb2bfc"
SRC_URI[sha256sum] = "a55535012b2be7a52dcd9eccabb9a198b13be50d0384143bd3b32b8710df4c1f"

INITSCRIPT_NAME = "init-daemontools.sh"
INITSCRIPT_PARAMS = "start 30 3 5 . stop 20 0 1 6 ."

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = "-r svcctrl"

do_install () {
    djbware_do_install

    install -d ${D}${sysconfdir}/init.d
    mv ${D}${bindir}/svscanboot ${D}${sysconfdir}/init.d/
    install -m 0755 ${WORKDIR}/init-daemontools.sh ${D}${sysconfdir}/init.d/

    # prepare for installing base-dir for services
    install -d 0755 ${D}${sysconfdir}/daemontools/service

    # allow %svcctrl to call svc
    install -d ${D}${sysconfdir}/sudoers.d
    install -m 600 ${WORKDIR}/sv-via-ctrl-grp.sudoers ${D}${sysconfdir}/sudoers.d/sv-via-ctrl-grp
}
