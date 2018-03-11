DESCRIPTION = "daemontools-encore is a collection of tools for managing UNIX services. \
It is derived from the public-domain release of daemontools by D. J. \
Bernstein.  It adds numerous enhancements above what daemontools could do \
while maintaining backwards compatibility with daemontools."

HOMEPAGE = "http://untroubled.org/daemontools-encore/"

LICENSE = "PD"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/PD;md5=b3597d12946881e13cb3b548d1173851"

inherit djbware update-rc.d useradd

#FILESEXTRAPATHS_prepend := "${THISDIR}/${PV}-${PV}:"

S = "${WORKDIR}/git"
DJB_CONFIG_DIR = "${S}"

SRCREV = "5526cf4499b9756d41e511422acd8cf47bb8c9c4"
SRC_URI = "git://github.com/bruceg/daemontools-encore.git \
	   file://init-daemontools-encore.sh \
	   file://sv-enc-via-ctrl-grp.sudoers \
	   file://do-no-run-crosscompiled.patch \
	   file://svscanboot-target-fs-adoptions.patch \
          "

INITSCRIPT_NAME = "init-daemontools-encore.sh"
INITSCRIPT_PARAMS = "start 30 3 5 . stop 20 0 1 6 ."

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = "-r svcctrl"

do_configure_append () {
    (cd ${S} && ./makemake)
}

do_compile () {
    oe_runmake || die "make failed"
}

do_install () {
    install -d ${D}/${bindir}
    for i in `awk -F: '{print $6}' <BIN`
    do
	install -m 0755 ${S}/$i ${D}/${bindir}/
    done
    install -d ${D}/${mandir}/man8/
    for i in `awk -F: '{print $6}' <MAN`
    do
	install -m 0644 ${S}/$i ${D}/${mandir}/man8/
    done

    install -d ${D}${sysconfdir}/init.d
    mv ${D}${bindir}/svscanboot ${D}${sysconfdir}/init.d/
    install -m 0755 ${WORKDIR}/init-daemontools-encore.sh ${D}${sysconfdir}/init.d/

    # prepare for installing base-dir for services
    install -d 0755 ${D}${sysconfdir}/daemontools/service

    # allow %svcctrl to call svc
    install -d ${D}${sysconfdir}/sudoers.d
    install -m 600 ${WORKDIR}/sv-enc-via-ctrl-grp.sudoers ${D}${sysconfdir}/sudoers.d/sv-enc-via-ctrl-grp
}

PROVIDES = "daemontools"
RPROVIDES_${PN} = "daemontools"
