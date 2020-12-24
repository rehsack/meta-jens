# IMAGE_FEATURES[validitems] += "updatable-base updatable-fetcher network-setup app-core app-extra app-devel app-shell-login"

def on_app_image(trueval, falseval, d):
    imgbn = d.getVar('IMAGE_BASENAME')
    if not imgbn:
        return falseval
    if imgbn.find('app') == -1:
        return falseval
    return trueval

FEATURE_PACKAGES_updatable-base = "package-group-updatable-image-base"
FEATURE_PACKAGES_updatable-fetcher = "package-group-updatable-image-fetcher"
FEATURE_PACKAGES_network-setup = "package-group-network-setup"
FEATURE_PACKAGES_network-setup-caching = "package-group-network-setup"
FEATURE_PACKAGES_network-setup-server = "package-group-network-setup"
FEATURE_PACKAGES_app-core = "package-group-app-core"
FEATURE_PACKAGES_app-extra = "package-group-app-extra"
FEATURE_PACKAGES_app-devel = "package-group-app-devel"
FEATURE_PACKAGES_app-shell-login = "package-group-app-shell-login"

UPDATABLE_IMAGE_CLASSES ??= ""
PACKAGE_ARCH ?= "${MACHINE_ARCH}-${WANTED_ROOT_DEV}"

UPDTIMGCLASSES = "core-image ${UPDATABLE_IMAGE_CLASSES}"

inherit ${UPDTIMGCLASSES}

UPDATABLE_IMAGE_EXTRA_INSTALL ??= ""

IMAGE_INSTALL_append = " ${UPDATABLE_IMAGE_EXTRA_INSTALL}"
