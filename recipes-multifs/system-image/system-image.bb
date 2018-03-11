DESCRIPTION = "Meta recipe for recording system image version"

LICENSE = "MIT"
PV = "${DISTRO_VERSION}"

MAINTAINER=     "HP2 Dev Team <verteiler.hp2dev.team@rademacher.de>"
HOMEPAGE=       "https://github.com/rdm-dev"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit record-installed-app
