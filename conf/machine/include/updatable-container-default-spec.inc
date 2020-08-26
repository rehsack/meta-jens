# Updatable Image Container - specify images

UPDATABLE_BUNDLE_HASH_ALGORITHMS ?= "size md5 rmd160 sha1"
UPDATABLE_BUNDLE_SIGN_ALGORITHM  ?= "sha256"

UPDATABLE_BUNDLE_MANIFEST ??= "manifest"

UPDATABLE_BUNDLE_HOOKS ??= ""
UPDATABLE_BUNDLE_HOOKS_append = " cleandeploy cleanupdate cleanbundle clean_volatile check_app check_updater"
UPDATABLE_BUNDLE_HOOKS[trigger] ?= "postverify preupdate postupdate predeploy postdeploy onfinish finishdeploy finishupdate"

UPDATABLE_BUNDLE_HOOK_cleandeploy[type] = "inline"
UPDATABLE_BUNDLE_HOOK_cleandeploy[trigger] = "finishdeploy"
UPDATABLE_BUNDLE_HOOK_cleandeploy[code] = "if test "${INTERNAL_ROOT_DEV}" = "${WANTED_ROOT_DEV}"; then reboot; else umount ${MNT_BOOT} ${MNT_DATA}; fi"

UPDATABLE_BUNDLE_HOOK_cleanupdate[type] = "inline"
UPDATABLE_BUNDLE_HOOK_cleanupdate[trigger] = "finishupdate"
UPDATABLE_BUNDLE_HOOK_cleanupdate[code] = "logger "Requesting reboot"; reboot"

UPDATABLE_BUNDLE_HOOK_cleanbundle[type] = "inline"
UPDATABLE_BUNDLE_HOOK_cleanbundle[trigger] = "onfinish"
UPDATABLE_BUNDLE_HOOK_cleanbundle[code] = "if test -n "${UPDATE_APP}" -a -z "${UPDATE_UPDATER}"; then umount "${BUNDLE_CONTAINER}"; rm -rf $(dirname ${BUNDLE_FILE}); fi"

UPDATABLE_BUNDLE_HOOK_clean_volatile[type] = "inline"
UPDATABLE_BUNDLE_HOOK_clean_volatile[trigger] = "postupdate"
UPDATABLE_BUNDLE_HOOK_clean_volatile[code] = "logger "Force rebuild of volatiles.cache next boot"; rm -f /etc/volatile.cache"

UPDATABLE_BUNDLE_HOOK_check_app[type] = "inline"
UPDATABLE_BUNDLE_HOOK_check_app[trigger] = "predeploy preupdate"
UPDATABLE_BUNDLE_HOOK_check_app[code] = "if test $(mount | grep "on / type" | sed -e "s/ on.*//") != "${PARTDEV_APP}"; then export UPDATE_APP=Y; fi"

UPDATABLE_BUNDLE_HOOK_check_updater[type] = "inline"
UPDATABLE_BUNDLE_HOOK_check_updater[trigger] = "predeploy preupdate"
UPDATABLE_BUNDLE_HOOK_check_updater[code] = "if test $(mount | grep "on / type" | sed -e "s/ on.*//") != "${PARTDEV_UPDATER}"; then export UPDATE_UPDATER=Y; fi"

UPDATABLE_BUNDLE_IMAGES ?= "APP UPDATER"

UPDATABLE_IMAGE_APP     ?= "updatable-image-app${UPDATABLE_BUNDLE_DEVELOPER_IMAGE_EXTNAME}"
UPDATABLE_IMAGE_UPDATER ?= "updatable-image-core${UPDATABLE_BUNDLE_DEVELOPER_IMAGE_EXTNAME}"

UPDATABLE_BUNDLE_SLOTS  += "${UPDATABLE_BUNDLE_IMAGES}"

UPDATABLE_SLOT_APP            ?= "${UPDATABLE_IMAGE_APP}"
UPDATABLE_SLOT_APP[type]      ?= "image"
UPDATABLE_SLOT_APP[file]      ?= "${UPDATABLE_IMAGE_APP}-${WANTED_ROOT_DEV}-${MACHINE}.${IMAGE_FSTYPES}"
UPDATABLE_SLOT_APP[dest]      ?= "partition"
UPDATABLE_SLOT_APP[condition] ?= "test "${UPDATE_APP}" = Y"
UPDATABLE_SLOT_UPDATER            ?= "${UPDATABLE_IMAGE_UPDATER}"
UPDATABLE_SLOT_UPDATER[type]      ?= "image"
UPDATABLE_SLOT_UPDATER[file]      ?= "${UPDATABLE_IMAGE_UPDATER}-${WANTED_ROOT_DEV}-${MACHINE}.${IMAGE_FSTYPES}"
UPDATABLE_SLOT_UPDATER[dest]      ?= "partition"
UPDATABLE_SLOT_UPDATER[condition] ?= "test "${UPDATE_UPDATER}" = Y"

UPDATABLE_PARTITIONS            ?= "BOOT APP UPDATER DATA"
UPDATABLE_PARTITIONS[type]      ?= "msdos"
UPDATABLE_PARTITIONS[alignment] ?= "1M"

UPDATABLE_PARTITION_BOOT[type]       ?= "partition"
UPDATABLE_PARTITION_BOOT[size]       ?= "32M"
UPDATABLE_PARTITION_BOOT[filesystem] ?= "ext4"
UPDATABLE_PARTITION_BOOT[fs_create]  ?= "-L boot-${MACHINE} -I128"
UPDATABLE_PARTITION_BOOT[fs_tune]    ?= "-L boot-${MACHINE} -O discard,block_validity"
UPDATABLE_PARTITION_BOOT[src]        ?= "none"
UPDATABLE_PARTITION_BOOT[mountpoint] ?= "/boot"

UPDATABLE_PARTITION_APP[type]       ?= "partition"
UPDATABLE_PARTITION_APP[size]       ?= "512M"
UPDATABLE_PARTITION_APP[filesystem] ?= "squashfs"
UPDATABLE_PARTITION_APP[src]        ?= "slot"
UPDATABLE_PARTITION_APP[slot]       ?= "APP"
UPDATABLE_PARTITION_APP[onmount]    ?= "UPDATE_UPDATER=Y"

UPDATABLE_PARTITION_UPDATER[type]       ?= "partition"
UPDATABLE_PARTITION_UPDATER[size]       ?= "128M"
UPDATABLE_PARTITION_UPDATER[filesystem] ?= "squashfs"
UPDATABLE_PARTITION_UPDATER[src]        ?= "slot"
UPDATABLE_PARTITION_UPDATER[slot]       ?= "UPDATER"

UPDATABLE_PARTITION_DATA[type]       ?= "partition"
UPDATABLE_PARTITION_DATA[size]       ?= "-1"
UPDATABLE_PARTITION_DATA[filesystem] ?= "ext4"
UPDATABLE_PARTITION_DATA[fs_create]  ?= "-L data-${MACHINE}"
UPDATABLE_PARTITION_DATA[fs_tune]    ?= "-L data-${MACHINE} -O journal_data,discard,block_validity"
# layout by volatile
UPDATABLE_PARTITION_DATA[src]        ?= "none"
UPDATABLE_PARTITION_DATA[mountpoint] ?= "/data"

