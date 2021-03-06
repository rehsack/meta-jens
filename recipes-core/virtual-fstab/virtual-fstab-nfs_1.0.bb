# Copyright (C) 2015 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

require virtual-fstab.inc

SRC_URI = "\
    file://fstab.nfs \
"

RDEPENDS_${PN} += " nfs-utils"

do_compile () {
    set -x
    cp ${WORKDIR}/fstab.nfs ${B}/fstab.${WANTED_ROOT_DEV}
    sed -i -e "s,@VLAN_GRP@,${VLAN_GRP},g" -e "s,@overlay@,${OVERLAY},g" \
        ${B}/fstab.${WANTED_ROOT_DEV}
}
