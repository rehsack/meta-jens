inherit core-image

# IMAGE_FEATURES[validitems] += "updatable-base updatable-fetcher network-setup app-core app-extra app-devel app-shell-login"

FEATURE_PACKAGES_updatable-base = "package-group-updatable-image-base"
FEATURE_PACKAGES_updatable-fetcher = "package-group-updatable-image-fetcher"
FEATURE_PACKAGES_network-setup = "package-group-network-setup"
FEATURE_PACKAGES_network-setup-caching = "package-group-network-setup"
FEATURE_PACKAGES_network-setup-server = "package-group-network-setup"
FEATURE_PACKAGES_app-core = "package-group-app-core"
FEATURE_PACKAGES_app-extra = "package-group-app-extra"
FEATURE_PACKAGES_app-devel = "package-group-app-devel"
FEATURE_PACKAGES_app-shell-login = "package-group-app-shell-login"

UPDATABLE_IMAGE_BASE_INSTALL = "\
	${CORE_IMAGE_BASE_INSTALL} \
	${UPDATABLE_IMAGE_EXTRA_INSTALL} \
"

IMAGE_INSTALL ?= "${UPDATABLE_IMAGE_BASE_INSTALL}"
