#
# This is to register/record installed key-apps without putting entire package
# database on target
#

inherit record-installed-common

do_install_append () {
        install -d "${D}/${RECORD_INSTALLED_DEST}"
	echo "${PV}-${PR}" >"${D}/${RECORD_INSTALLED_DEST}/${PN}"
	chmod 644 "${D}/${RECORD_INSTALLED_DEST}/${PN}"
}

FILES_${PN} += "${RECORD_INSTALLED_DEST}"
