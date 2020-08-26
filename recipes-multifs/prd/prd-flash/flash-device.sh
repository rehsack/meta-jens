#!/bin/sh
### BEGIN INIT INFO
# Provides:             flash-production
# Required-Start:       $local_fs
# Required-Stop:      $local_fs
# Default-Start:
# Default-Stop:
# Short-Description:  Flash internal/external sd-card
### END INIT INFO

set -x

@NFS_FLASH@logger -s "Prove being the one and only ..."
@NFS_FLASH@test "${FLOCKER}" != "@ARGV0@" && exec env FLOCKER="@ARGV0@" flock -en "@ARGV0@" "@ARGV0@" || :
logger -s "Starting flash ..."

. @LIBEXEC@/init
. @LIBEXEC@/algorithms

# use last found image container
for bf in /data/.flashimg/*.sfsuc /data/flashimg/*.sfsuc
do
    if [ -f "${bf}" ]
    then
	if ! prove_bundle "${bf}"; then continue; fi

	BUNDLE_FILE="${bf}"
	BUNDLE_CONTAINER=$(dirname "${bf}")/$(basename "${bf}" .sfsuc)
	mkdir -p ${BUNDLE_CONTAINER}
	mount -t squashfs ${bf} ${BUNDLE_CONTAINER}

	break
    fi
done

test -z "${BUNDLE_CONTAINER}" && exit 0

. "${BUNDLE_CONTAINER}"/@MANIFEST_NAME@
. @LIBEXEC@/init.${WANTED_ROOT_DEV}

if [ "${MACHINE}" != "$(echo @MACHINE@ | sed -e 's/-*//')" ]
then
    logger -s "Cannot perform an update for ${MACHINE} on @MACHINE@."
    trigger_error
fi

if [ "@FLASH_MODE@" = "update" -a "$WANTED_ROOT_DEV" != "@WANTED_ROOT_DEV@" ]
then
    logger -s "Cannot write to ${WANTED_ROOT_DEV}, flashing limited to @WANTED_ROOT_DEV@."
    trigger_error
fi

for tmp in /var/tmp /data/tmp /tmp
do
    touch ${tmp}/$$ && rm ${tmp}/$$ && TEMP_DIR=${tmp} && break
done

cd ${TEMP_DIR}/

for hook in ${TRIGGER_postverify}
do
    eval "hc=\"\$HOOK_${hook}\""
    eval $hc
done

prepare_@FLASH_MODE@

for hook in ${TRIGGER_pre@FLASH_MODE@}
do
    eval "hc=\"\$HOOK_${hook}\""
    eval $hc
done

for slot in ${CONTAINS}
do
    COND="/bin/true"
    eval "test -n \"\$${slot}_CONDITION\" && COND=\"\$${slot}_CONDITION\""
    eval "${COND} || continue"
    eval "write_${slot}"
    eval "test -n \"\$${slot}_HOOK\" && \$${slot}_HOOK"
done

for hook in ${TRIGGER_post@FLASH_MODE@}
do
    eval "hc=\"\$HOOK_${hook}\""
    eval $hc
done

sync

for hook in ${TRIGGER_onfinish}
do
    eval "hc=\"\$HOOK_${hook}\""
    eval $hc
done

for hook in ${TRIGGER_finish@FLASH_MODE@}
do
    eval "hc=\"\$HOOK_${hook}\""
    eval $hc
done
