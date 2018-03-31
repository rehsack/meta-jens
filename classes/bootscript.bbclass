inherit deploy

BOOTSCRIPT_FILE_NAME ?= "bootscript-${DATETIME}.${WANTED_ROOT_DEV}"
BOOTSCRIPT_FILE_NAME[vardepsexclude] = "DATETIME"

do_deploy () {
    set -x
    cp ${D}/boot/bootscript.${WANTED_ROOT_DEV} ${DEPLOYDIR}/${BOOTSCRIPT_FILE_NAME}
    ln -sf ${BOOTSCRIPT_FILE_NAME} ${DEPLOYDIR}/bootscript.${WANTED_ROOT_DEV}
    ln -sf ${BOOTSCRIPT_FILE_NAME} ${DEPLOYDIR}/bootscript
    : # exit 0
}

addtask deploy after do_install
