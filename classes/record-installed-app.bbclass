#
# This is to record installed key-apps without putting entire package
# database on target
#

RECORD_INSTALLED_DEST ?= "/opt/record-installed"

do_install_append () {
        install -d "${D}/${RECORD_INSTALLED_DEST}"
	echo "${PV}-${PR}" >"${D}/${RECORD_INSTALLED_DEST}/${PN}"
	chmod 644 "${D}/${RECORD_INSTALLED_DEST}/${PN}"
}

FILES_${PN} += "${RECORD_INSTALLED_DEST}"
