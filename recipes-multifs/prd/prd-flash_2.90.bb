DESCRIPTION = "Initscript for flashing images at boot"

OPN := "${PN}"
PN = "${OPN}-${WANTED_ROOT_DEV}"
FILESEXTRAPATHS_prepend := "${THISDIR}/${OPN}:"

include recipes-multifs/prd/${PN}.inc

LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

PACKAGE_ARCH = "${MACHINE_ARCH}-${WANTED_ROOT_DEV}"

SRC_URI = "\
    file://flash-device.sh \
    file://init.generic \
    file://init.${ROOT_DEV_TYPE} \
    file://post.generic \
"

DEPENDS += " update-rc.d-native"
# append to the base setting from ${OPN}-${WANTED_ROOT_DEV}.inc
RDEPENDS_${PN}_append = "\
    perl-module-version \
    util-linux \
    u-boot-fw-utils \
"

def all_root_dev_names (d) :
    rc = []
    avail_root_devs = d.getVar("AVAIL_ROOT_DEVS", True).split(" ")
    for dev in avail_root_devs:
        devnm = "ROOT_DEV_NAME-" + dev
        rc.append(devnm + "='" + d.getVar(devnm, True) + "'")
    return " ".join(rc)

FINALIZE_FLASH = "reboot"

do_compile () {
    set -x

    EXPECTED_CONTENT="KERNEL"
    test -n "${SPL_BINARY}" && EXPECTED_CONTENT="${EXPECTED_CONTENT} SPL"
    test -n "${UBOOT_MACHINE}" && EXPECTED_CONTENT="${EXPECTED_CONTENT} UBOOT"
    EXPECTED_CONTENT="${EXPECTED_CONTENT} ROOTIMG RECOVERIMG"

    SANITIZED_SRC=""
    SANITIZED_SRC_S=""
    for u in ${SRC_URI}
    do
	f="${WORKDIR}/"$(echo "$u" | sed -e 's,file://,,g')
        test -f "$f" || continue
        SANITIZED_SRC="${SANITIZED_SRC}${SANITIZED_SRC_S}${f}"
        SANITIZED_SRC_S=" "
    done
    cp -a ${SANITIZED_SRC} ${B}

    SANITIZED_BLD=$(echo ${SANITIZED_SRC} | sed -e "s,${WORKDIR},${B},g")

    sed -i -e "s,@ARGV0@,${sysconfdir}/init.d/flash-device,g" \
        -e "s,@LIBEXEC[@],${libexecdir}/flash-device,g" -e "s,@LEDCTRL[@],${libexecdir}/ledctrl,g" \
        -e "s/@MACHINE[@]/${MACHINE}/g" -e "s,@AVAIL_ROOT_DEVS[@],${AVAIL_ROOT_DEVS},g" \
        -e "s,@INTERNAL_ROOT_DEV[@],${INTERNAL_ROOT_DEV},g" -e "s,@WANTED_ROOT_DEV[@],${WANTED_ROOT_DEV},g" \
        -e "s,@ROOT_DEV_TYPE[@],${ROOT_DEV_TYPE},g" -e "s,@ROOT_DEV_SEP[@],${ROOT_DEV_SEP},g" \
        -e "s,@BOOTABLE_ROOT_DEVS[@],${BOOTABLE_ROOT_DEVS},g" -e "s,@FINALIZE_FLASH[@],${FINALIZE_FLASH},g" \
        -e "s,@EXPECTED_CONTENT[@],${EXPECTED_CONTENT},g" -e "s,@ALGORITHMS[@],${IMAGE_PROTECT_ALGORITHMS},g" \
        -e "s,@NFS_FLASH[@],${NFS_FLASH},g" \
        ${SANITIZED_BLD}

    if [ ! -f ${B}/hw.${MACHINE} ]
    then
        echo "AVAIL_ROOT_DEVS='${AVAIL_ROOT_DEVS}'" > ${B}/hw.${MACHINE}
        for d in ${@all_root_dev_names(d)}
        do
            echo "$d" | sed -e 's/-/_/g' >> ${B}/hw.${MACHINE}
        done
    fi

}

do_install () {
    set -x

    install -d ${D}${sysconfdir}/init.d
    install -d ${D}${libexecdir}/flash-device

    install -m 0755 ${B}/flash-device.sh ${D}${sysconfdir}/init.d/flash-device
    install -m 0644 ${B}/hw.${MACHINE} ${D}${libexecdir}/flash-device/hw
    for f in ${B}/init.${MACHINE} ${B}/init.generic
    do
        test -f $f || continue
        install -m 0644 $f ${D}${libexecdir}/flash-device/init
        break
    done
    test -f ${B}/init.${ROOT_DEV_TYPE} && install -m 0644 ${B}/init.${ROOT_DEV_TYPE} ${D}${libexecdir}/flash-device/init.${ROOT_DEV_TYPE}
    update-rc.d -r ${D} flash-device start 25 3 5 .
}

FILES_${PN} += "${libexecdir}/flash-device"
