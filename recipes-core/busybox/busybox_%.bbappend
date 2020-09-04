FILESEXTRAPATHS_append := "${THISDIR}/files:${THISDIR}/busybox:"

SRC_URI += "\
    file://arping.cfg \
    file://nice.cfg \
    file://unix-local.cfg \
    file://simple.hostname \
    file://ls.cfg \
    \
    file://0001-ifupdown-improve-debian-compatibility-for-mapping.patch \
    file://0002-udhcpc-calculate-broadcast-address-if-not-given-by-s.patch \
    file://0003-udhcpc-obtain-hostname-from-OS-by-default.patch \
"

DEBUG_TWEAKS_SRC_URI = "\
    file://netstat.cfg \
    file://procstat.cfg \
    file://pstree.cfg \
"

NETWORK_SETUP_SRC_URI = "\
    file://udhcp.cfg \
    file://udhcpc-opts.cfg \
    \
    file://ifupdown.cfg \
"

WIFI_ETH_AUTO_ENABLE_SRC_URI = "\
    file://ifplugd.cfg \
    file://ifplugd/ifplugd.action \
    file://ifplugd/ifplugd.conf \
    file://ifplugd/ifplugd.default-wifi \
    file://ifplugd/ifplugd.init \
"

NO_ASH_SRC_URI = "\
    file://no-ash.cfg \
"

BASH_ASH_SRC_URI = "\
    file://bash-ash.cfg \
"

FANCY_HEAD_SRC_URI = "\
    file://fancy-head.cfg \
"

NO_IFCONFIG_SRC_URI = "\
    file://no-if-sysctl.cfg \
"

NO_MKNOD_SRC_URI = "\
    file://no-mknod.cfg \
"

NO_PROCPS_SRC_URI = "\
    file://no-procps.cfg \
"

NO_REALPATH_SRC_URI = "\
    file://no-realpath.cfg \
"

NO_SWAPUTILS_SRC_URI = "\
    file://no-swaputils.cfg \
"

NO_UTMPUTILS_SRC_URI = "\
    file://no-utmputils.cfg \
"

NO_UTILLINUX_SRC_URI = "\
    file://no-util-linux.cfg \
"

PACKAGECONFIG_DEBUG_TWEAKS = "${@bb.utils.contains("IMAGE_FEATURES", 'debug-tweaks', 'debug-tweaks', '', d )}"
PACKAGECONFIG_WIFI_AUTO = "${@bb.utils.contains("MACHINE_FEATURES", 'wifi', 'wifi-choose', '', d )}"

PACKAGECONFIG ?= "\
    bash-ash \
    fancy-head \
    network-setup \
    ${PACKAGECONFIG_DEBUG_TWEAKS} \
    ${PACKAGECONFIG_WIFI_AUTO} \
    no-ifconfig \
    no-realpath \
    no-swaputils \
    no-utmputils \
    no-util-linux \
"

PACKAGECONFIG[debug-tweaks] = ""
PACKAGECONFIG[network-setup] = ""
PACKAGECONFIG[wifi-choose] = ""
PACKAGECONFIG[no-ash] = ""
PACKAGECONFIG[bash-ash] = ""
PACKAGECONFIG[fancy-head] = ""
PACKAGECONFIG[no-ifconfig] = ""
PACKAGECONFIG[no-mknod] = ""
PACKAGECONFIG[no-procps] = ""
PACKAGECONFIG[no-realpath] = ""
PACKAGECONFIG[no-swaputils] = ""
PACKAGECONFIG[no-utmputils] = ""
PACKAGECONFIG[no-util-linux] = ""

SRC_URI += "${@bb.utils.contains("PACKAGECONFIG", 'debug-tweaks', '  ', '', d )}"
SRC_URI += "${@bb.utils.contains("PACKAGECONFIG", 'network-setup', ' ${NETWORK_SETUP_SRC_URI} ', '', d )}"
SRC_URI += "${@bb.utils.contains("PACKAGECONFIG", 'wifi-choose', ' ${WIFI_ETH_AUTO_ENABLE_SRC_URI} ', '', d )}"
SRC_URI += "${@bb.utils.contains("PACKAGECONFIG", 'fancy-head', ' ${FANCY_HEAD_SRC_URI} ', '', d )}"
SRC_URI += "${@bb.utils.contains("PACKAGECONFIG", 'bash-ash', ' ${BASH_ASH_SRC_URI} ', '', d )}"
SRC_URI += "${@bb.utils.contains("PACKAGECONFIG", 'no-ash', ' ${NO_ASH_SRC_URI} ', '', d )}"
SRC_URI += "${@bb.utils.contains("PACKAGECONFIG", 'no-procps', ' ${NO_PROCPS_SRC_URI} ', '', d )}"
SRC_URI += "${@bb.utils.contains("PACKAGECONFIG", 'no-realpath', ' ${NO_REALPATH_SRC_URI} ', '', d )}"
SRC_URI += "${@bb.utils.contains("PACKAGECONFIG", 'no-swaputils', ' ${NO_SWAPUTILS_SRC_URI} ', '', d )}"
SRC_URI += "${@bb.utils.contains("PACKAGECONFIG", 'no-utmputils', ' ${NO_UTMPUTILS_SRC_URI} ', '', d )}"
SRC_URI += "${@bb.utils.contains("PACKAGECONFIG", 'no-util-linux', ' ${NO_UTILLINUX_SRC_URI} ', '', d )}"

inherit ${@bb.utils.contains("PACKAGECONFIG", 'wifi-choose', 'supervised', 'supervised-base', d )}

PACKAGES_WIFI_CHOOSE = "${@bb.utils.contains("PACKAGECONFIG", 'wifi-choose', ' ${PN}-ifplugd ', '', d )}"

PACKAGES =+ "${PACKAGES_WIFI_CHOOSE}"
INITSCRIPT_NAME_${PN}-ifplugd = "ifplugd.init"
INITSCRIPT_PARAMS_${PN}-ifplugd = "defaults 05"
INITSCRIPT_PACKAGES += "${PN}-ifplugd"
FILES_${PN}-ifplugd = "${sysconfdir}/init.d/busybox-ifplugd ${sysconfdir}/rc*/*busybox-ifplugd ${sysconfdir}/ifplugd ${SERVICE_DIR}"

SUPERVISED_PACKAGES = "${PACKAGES_WIFI_CHOOSE}"

SERVICE_NAME_${PN}-ifplugd = "default-wifi"
SERVICE_DIR_${PN}-ifplugd ?= "${SERVICE_ROOT}/${SERVICE_NAME_${PN}-ifplugd}"
SERVICE_RUN_SCRIPT_NAME_${PN}-ifplugd = "ifplugd/ifplugd.default-wifi"
SERVICE_RUN_SCRIPT_DOWN_${PN}-ifplugd = "down"
SERVICE_LOG_SCRIPT_NAME_${PN}-ifplugd = "log"

PROVIDES_append = "${@bb.utils.contains("PACKAGECONFIG", 'network-setup', ' ifupdown ', '', d )}"
RPROVIDES_${PN}_append = "${@bb.utils.contains("PACKAGECONFIG", 'network-setup', ' ifupdown ', '', d )}"
PROVIDES_append = "${@bb.utils.contains("PACKAGECONFIG", 'no-procps', '', 'procps', d )}"
RPROVIDES_${PN}_append = "${@bb.utils.contains("PACKAGECONFIG", 'no-procps', '', 'procps', d )}"

RRECOMMENDS_${PN}_append =  "${@bb.utils.contains("PACKAGECONFIG", 'network-setup', ' ${PACKAGES_WIFI_CHOOSE} ', '', d )}"

do_compile_append () {
	if grep -q "CONFIG_IFPLUGD=y" ${B}/.config; then
		sed -i -e "s,@DEFAULT_ETH_DEV[@],${DEFAULT_ETH_DEV},g" -e "s,@DEFAULT_WIFI_DEV[@],${DEFAULT_WIFI_DEV},g" \
		       -e "s,@BINDIR[@],${bindir},g" -e "s,@SERVICE_DIR[@],${SERVICE_DIR_${PN}-ifplugd},g" \
		       -e "s,@SVC_STATUS_CMD[@],${SVC_STATUS_CMD},g" -e "s,@SVC_ONCE_CMD[@],${SVC_ONCE_CMD},g" \
		    ${WORKDIR}/ifplugd/ifplugd.action ${WORKDIR}/ifplugd/ifplugd.conf ${WORKDIR}/ifplugd/ifplugd.default-wifi
	fi
}

do_install_append() {
    if grep -q "CONFIG_IFPLUGD=y" ${B}/.config; then
        if ${@bb.utils.contains('DISTRO_FEATURES', 'sysvinit', 'true', 'false', d)}
        then
            install -m 0755 ${WORKDIR}/ifplugd/ifplugd.init ${D}${sysconfdir}/init.d/
        fi

        install -d ${D}${sysconfdir}/ifplugd
        install -m 0755 ${WORKDIR}/ifplugd/ifplugd.action ${D}${sysconfdir}/ifplugd/ifplugd.action
        install -m 0644 ${WORKDIR}/ifplugd/ifplugd.conf ${D}${sysconfdir}/ifplugd/ifplugd.conf
    fi

    if grep -q "CONFIG_UDHCPC=y" ${B}/.config; then
	install -m 0755 ${WORKDIR}/simple.hostname ${D}${sysconfdir}/udhcpc.d/51hostname
    fi
}
