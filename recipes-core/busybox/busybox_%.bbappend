FILESEXTRAPATHS_append := "${THISDIR}/files:${THISDIR}/busybox:"

SRC_URI += "\
    file://udhcpc-opts.cfg \
    file://netstat.cfg \
    file://nice.cfg \
    file://unix-local.cfg \
    file://udhcp.cfg \
    file://simple.hostname \
    file://ifupdown.cfg \
    file://ifplugd.cfg \
    file://ifplugd/ifplugd.action \
    file://ifplugd/ifplugd.conf \
    file://ifplugd/ifplugd.default-wifi \
    file://ifplugd/ifplugd.init \
    file://pstree.cfg \
    file://user.cfg \
    file://ls.cfg \
    file://mknod.cfg \
    file://realpath.cfg \
    file://procps.cfg \
    file://swap.cfg \
    file://util-linux.cfg \
    file://ash.cfg \
    file://if-sysctl.cfg \
    file://arping.cfg \
    \
    file://0001-ifupdown-improve-debian-compatibility-for-mapping.patch \
    file://0001-udhcpc-obtain-hostname-from-OS-by-default.patch \
"

SRC_URI += "${@bb.utils.contains("IMAGE_FEATURES", 'debug-tweaks', ' file://procstat.cfg ', '', d )}"

SERVICE_ROOT = "${sysconfdir}/daemontools/service"
DEFWIFI_SERVICE_DIR = "${SERVICE_ROOT}/default-wifi"

PACKAGES =+ "${PN}-ifplugd"
FILES_${PN}-ifplugd = "${sysconfdir}/init.d/busybox-ifplugd ${sysconfdir}/rc*/*busybox-ifplugd ${sysconfdir}/ifplugd ${DEFWIFI_SERVICE_DIR}"
RDEPENDS_${PN}-ifplugd += " daemontools"

DEPENDS_append = " update-rc.d-native"

do_compile_append () {
    sed -i -e "s,@DEFAULT_ETH_DEV[@],${DEFAULT_ETH_DEV},g" -e "s,@DEFAULT_WIFI_DEV[@],${DEFAULT_WIFI_DEV},g" \
        -e "s,@BINDIR[@],${bindir},g" \
        ${WORKDIR}/ifplugd/ifplugd.action ${WORKDIR}/ifplugd/ifplugd.conf ${WORKDIR}/ifplugd/ifplugd.default-wifi
}

do_install_append() {
    if grep -q "CONFIG_IFPLUGD=y" ${B}/.config; then
        install -m 0755 ${WORKDIR}/ifplugd/ifplugd.init ${D}${sysconfdir}/init.d/busybox-ifplugd

        install -d ${D}${sysconfdir}/ifplugd
        install -m 0755 ${WORKDIR}/ifplugd/ifplugd.action ${D}${sysconfdir}/ifplugd/ifplugd.action
        install -m 0644 ${WORKDIR}/ifplugd/ifplugd.conf ${D}${sysconfdir}/ifplugd/ifplugd.conf

	install -d ${D}${DEFWIFI_SERVICE_DIR}

	# install svc run script and make it executable
	install -m 0755 ${WORKDIR}/ifplugd/ifplugd.default-wifi ${D}${DEFWIFI_SERVICE_DIR}/run
	touch ${D}${DEFWIFI_SERVICE_DIR}/down

        update-rc.d -r ${D} busybox-ifplugd defaults 05
    fi

    if grep -q "CONFIG_UDHCPC=y" ${B}/.config; then
	install -m 0755 ${WORKDIR}/simple.hostname ${D}${sysconfdir}/udhcpc.d/51hostname
    fi
}
