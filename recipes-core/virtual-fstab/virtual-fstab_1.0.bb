require virtual-fstab.inc

PN = "virtual-fstab-${WANTED_ROOT_DEV}"

SRC_URI = "\
    file://fstab \
"

SRC_URI_bohr-update = "\
    file://fstab.nfs \
"

do_compile_bohr-update () {
    set -x
    cp ${WORKDIR}/fstab.nfs ${B}/fstab.${WANTED_ROOT_DEV}
}
