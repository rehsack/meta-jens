do_install_append() {
    rm ${D}${sysconfdir}/udev/rules.d/autonet.rules ${D}${sysconfdir}/udev/scripts/network.sh
}
