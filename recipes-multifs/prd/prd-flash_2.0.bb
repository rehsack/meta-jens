DESCRIPTION = "Initscript for flashing images at boot"

OPN := "${PN}"
PN = "${OPN}-${WANTED_ROOT_DEV}"
FILESEXTRAPATHS_prepend := "${THISDIR}/${OPN}:"

include recipes-multifs/prd/${PN}.inc
inherit update-rc.d

LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

PACKAGE_ARCH = "${MACHINE_ARCH}"

SRC_URI = "\
    file://flash-device.sh \
    file://init.generic \
    file://init.${ROOT_DEV_TYPE} \
    file://post.generic \
"

# append to the base setting from ${OPN}-${WANTED_ROOT_DEV}.inc
RDEPENDS_${PN}_append = "\
    perl-module-version \
    util-linux \
    u-boot-fw-utils \
"

def all_root_dev_names (d) :
    rc = []
    root_dev_names = d.getVar("AVAIL_ROOT_DEVS", True).split(" ")
    for dev in root_dev_names:
        devnm = "ROOT_DEV_NAME-" + dev
        rc.append(devnm + "='" + d.getVar(devnm, True) + "'")
    return " ".join(rc)

FINALIZE_FLASH = "reboot"

do_compile () {
    set -x

    SANITIZED_SRC=""
    SANITIZED_SRC_S=""
    for f in ${WORKDIR}/flash-device.sh ${WORKDIR}/*.{${MACHINE},generic} ${WORKDIR}/init.*
    do
        test -f "$f" || continue
        SANITIZED_SRC="${SANITIZED_SRC}${SANITIZED_SRC_S}${f}"
        SANITIZED_SRC_S=" "
    done
    cp -a ${SANITIZED_SRC} ${B}

    SANITIZED_BLD=$(echo ${SANITIZED_SRC} | sed -e "s,${WORKDIR},${B},g")

    sed -i -e "s,@ARGV0@,${sysconfdir}/init.d/flash-device.sh,g" \
        -e "s,@LIBEXEC[@],${libexecdir},g" -e "s,@LEDCTRL[@],${libdir}/ledctrl,g" \
        -e "s/@MACHINE[@]/${MACHINE}/g" -e "s,@AVAIL_ROOT_DEVS[@],${AVAIL_ROOT_DEVS},g" \
        -e "s,@INTERNAL_ROOT_DEV[@],${INTERNAL_ROOT_DEV},g" -e "s,@WANTED_ROOT_DEV[@],${WANTED_ROOT_DEV},g" \
        -e "s,@ROOT_DEV_TYPE[@],${ROOT_DEV_TYPE},g" -e "s,@ROOT_DEV_SEP[@],${ROOT_DEV_SEP},g" \
        -e "s,@BOOTABLE_ROOT_DEVS[@],${BOOTABLE_ROOT_DEVS},g" -e "s,@FINALIZE_FLASH[@],${FINALIZE_FLASH},g" \
        ${SANITIZED_BLD}

    if [ ! -f ${B}/hw.${MACHINE} ]
    then
        echo "AVAIL_ROOT_DEVS='${AVAIL_ROOT_DEVS}'" > ${B}/hw.${MACHINE}
        for d in ${@all_root_dev_names(d)}
        do
            echo "$d" >> ${B}/hw.${MACHINE}
        done
    fi

}

do_install () {
    install -d ${D}${sysconfdir}/init.d
    install -d ${D}${libexecdir}

    install -m 0755 ${B}/flash-device.sh ${D}${sysconfdir}/init.d/flash-device
    install -m 0644 ${B}/hw.${MACHINE} ${D}${libexecdir}/hw
    for f in ${B}/init.{${MACHINE},generic}
    do
        test -f $f || continue
        install -m 0644 $f ${D}${libexecdir}/init
        break
    done
    install -m 0644 ${B}/init.${ROOT_DEV_TYPE} ${D}${libexecdir}/init.${ROOT_DEV_TYPE}
}

INITSCRIPT_NAME = "flash-device"
INITSCRIPT_PARAMS = "25 3 5 ."

FILES_${PN} += "${libexecdir}"
