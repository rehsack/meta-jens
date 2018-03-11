inherit deploy

do_deploy () {
    set -x
    cp ${D}/boot/bootscript.${WANTED_ROOT_DEV} ${DEPLOYDIR}/bootscript.${WANTED_ROOT_DEV}-${DATETIME}
    ln -sf bootscript.${WANTED_ROOT_DEV}-${DATETIME} ${DEPLOYDIR}/bootscript.${WANTED_ROOT_DEV}
    ln -sf bootscript.${WANTED_ROOT_DEV}-${DATETIME} ${DEPLOYDIR}/bootscript
    : # exit 0
}

addtask deploy after do_install
