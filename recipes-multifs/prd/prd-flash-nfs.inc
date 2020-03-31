def all_root_dev_type_sources (d) :
    rc = []
    avail_root_devs = d.getVar("AVAIL_ROOT_DEVS", True).split(" ")
    for dev in avail_root_devs:
        devnm = "ROOT_DEV_TYPE-" + dev
        rc.append("file://init." + d.getVar(devnm, True))
    return " ".join(rc)



RDEPENDS_${PN} = "\
	parted \
	e2fsprogs \
	e2fsprogs-tune2fs \
"

SRC_URI_remove = "\
	file://init.${ROOT_DEV_TYPE} \
"

SRC_URI_append = "\
	file://algorithms \
	${@all_root_dev_type_sources(d)} \
"

NFS_FLASH = "#"

do_install_append () {
    install -m 0644 ${B}/algorithms ${D}${libexecdir}/flash-device/
    for f in ${B}/post.${MACHINE} ${B}/post.generic
    do
        test -f $f || continue
        install -m 0644 $f ${D}${libexecdir}/flash-device/post
        break
    done
    for u in ${@all_root_dev_type_sources(d)}
    do
	f="${B}/"$(echo "$u" | sed -e 's,file://,,g')
        install -m 0644 $f ${D}${libexecdir}/flash-device/
    done
}
