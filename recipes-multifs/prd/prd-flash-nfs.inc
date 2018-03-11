RDEPENDS_${PN} = "\
    parted \
    openssl \
"

SRC_URI_append = "\
    file://algorithms \
"

do_install_append () {
    install -m 0644 ${WORKDIR}/algorithms ${D}${libexecdir}
    for f in ${B}/post.{${MACHINE},generic}
    do
        test -f $f || continue
        install -m 0644 $f ${D}${libexecdir}/post
        break
    done
}
