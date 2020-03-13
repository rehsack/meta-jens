# Copyright (C) 2020 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Image network setup tools"
DESCRIPTION = "Package group for setting up network configuration and behaviour"
HOMEPAGE = "https://github.com/rehsack/"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = "${PN} ${PN}-caching ${PN}-server"

# dhclient, ...
# ntp

RDEPENDS_${PN} = "\
	ntpdate \
	ntp-utils \
	date-set \
	ifupdown \
"

RDEPENDS_${PN}-caching = "\
	dnsmasq \
"

# ntpd, bind, dhcpd ...

RDEPENDS_${PN}-server = "\
	dnsmasq \
"
