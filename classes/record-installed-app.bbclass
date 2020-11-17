#
# This is to register/record installed key-apps without putting entire package
# database on target
#

inherit record-installed-common

do_install_append () {
        install -d "${D}/${RECORD_INSTALLED_DEST}"
	case "${PV}" in
	git|svn)
		echo "${PV}-${SRCPV}" >"${D}/${RECORD_INSTALLED_DEST}/${PN}"
		;;
	*)
		echo "${PV}-${PR}" >"${D}/${RECORD_INSTALLED_DEST}/${PN}"
		;;
	esac
	chmod 644 "${D}/${RECORD_INSTALLED_DEST}/${PN}"
}

FILES_${PN} += "\
	${RECORD_INSTALLED_DEST}/${PN} \
"
