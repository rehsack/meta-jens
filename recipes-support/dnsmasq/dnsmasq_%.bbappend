do_compile:append() {
    sed -i -e 's/^#bind-interfaces/bind-interfaces/' ${WORKDIR}/dnsmasq.conf
}
