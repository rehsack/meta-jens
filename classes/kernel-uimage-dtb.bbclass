inherit kernel-uboot

python __anonymous () {
    kerneltype = d.getVar('KERNEL_IMAGETYPE', True)
    if kerneltype == 'uImage':
        depends = d.getVar("DEPENDS", True)
        depends = "%s u-boot-mkimage-native" % depends
        d.setVar("DEPENDS", depends)

        d.setVar("KERNEL_IMAGETYPE_FOR_MAKE", "zImage")
}

do_uboot_w_dtb_mkimage() {
    if test "x${KERNEL_IMAGETYPE}" = "xuImage" ; then
        ENTRYPOINT=${UBOOT_ENTRYPOINT}
        if test -n "${UBOOT_ENTRYSYMBOL}"; then
            ENTRYPOINT=`${HOST_PREFIX}nm ${S}/vmlinux | awk '$3=="${UBOOT_ENTRYSYMBOL}" {print $1}'`
        fi

        cat arch/${ARCH}/boot/zImage arch/${ARCH}/boot/dts/${KERNEL_DEVICETREE} > arch/${ARCH}/boot/zImage_w_dtb
        uboot-mkimage -A ${UBOOT_ARCH} -O linux -T kernel -C "none" -a ${UBOOT_LOADADDRESS} -e $ENTRYPOINT \
                -n "${DISTRO_NAME}/${PV}/${MACHINE}" \
                -d arch/${ARCH}/boot/zImage_w_dtb arch/${ARCH}/boot/uImage
    fi
}

addtask uboot_w_dtb_mkimage before do_install after do_compile
