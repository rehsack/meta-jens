DESCRIPTION = "Initscript for flashing images at boot"

OPN := "${PN}"
PN = "${OPN}-${WANTED_ROOT_DEV}"
FILESEXTRAPATHS_prepend := "${THISDIR}/${OPN}:"

inherit system-image-update

include recipes-multifs/prd/${PN}.inc

LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

PACKAGE_ARCH = "${MACHINE_ARCH}-${WANTED_ROOT_DEV}"

FLASH_MODE ??= "update"

SRC_URI = "\
    file://flash-device.sh \
    file://init.generic \
    file://algorithms \
"

def is_uboot_bootloader(trueval, falseval, d):
    bootloader = d.getVar('PREFERRED_PROVIDER_virtual/bootloader')
    if not bootloader:
        return falseval
    if bootloader.find('u-boot') == -1:
        return falseval
    return trueval

DEPENDS += "update-rc.d-native libubootenv openssl-native"
# append to the base setting from ${OPN}-${WANTED_ROOT_DEV}.inc
RDEPENDS_${PN}_append = "\
        file \
        openssl-bin \
        perl-module-version \
        util-linux \
        ${@is_uboot_bootloader('libubootenv-bin', '', d)} \
"

def number_in_sectors (n, d):
    d = {"M":2048, "m":2048, "K":2, "k":2, "G":2097152, "g":2097152}
    if not n[-1:].isdigit():
        unit = n[-1:]
        n = n[:-1]
        if unit not in d:
            bb.warn("Unknown unit for size: %s" % unit)
            u = 1
        else:
            u = d[unit]

        n = int(n) * u
    else:
        n = int(n)

    return n

def sectors_to_KiB (n, d):
    m = n / 2
    if (n % 2) != 0:
        m += 1
    return m

def sectors_to_MiB (n, d):
    m = n / 2048
    if (n % 2048) != 0:
        m += 1
    return m

def write_disc_access (wrt, d):
    import shutil

    build_path = d.expand("${B}")
    disc_writer_name = "init.%s" % wrt
    bb.utils.mkdirhier(build_path)
    try:
        disc_writer = open('%s/%s' % (build_path, disc_writer_name), 'w')
    except OSError:
        raise bb.build.FuncFailed('Unable to open %s' % disc_writer_name)

    device_name = d.getVar('ROOT_DEV_NAME-%s' % wrt)
    device_sep  = d.getVar('ROOT_DEV_SEP-%s'  % wrt)
    device_type = d.getVar('ROOT_DEV_TYPE-%s' % wrt)

    part_no = 1
    next_ofs = 0;

    disc_writer.write("prepare_deploy () {\n")
    disc_writer.write("    set -x\n")
    disc_writer.write("\n")
    disc_writer.write("    if [ ! -e /dev/%s ]\n" % device_name)
    disc_writer.write("    then\n")
    disc_writer.write('        logger -s "Cannot flash image on %s: /dev/%s not found"\n' % (wrt, device_name))
    disc_writer.write("        trigger_error\n")
    disc_writer.write("    fi\n")

    if device_type == "ssd":
        disc_writer.write("\n")
        disc_writer.write("    # wipe them out ... all of them\n")
        disc_writer.write("    blkdiscard -f /dev/%s\n" % device_name)
        disc_writer.write("\n")
        disc_writer.write("    DEV_SIZE=$(/sbin/fdisk -l /dev/%s | /bin/grep \"Disk /dev/%s\" | /usr/bin/awk '{print $5}')\n" % (device_name, device_name))
        disc_writer.write("    DEV_SIZE=$(expr $DEV_SIZE \/ 1024)\n")
        disc_writer.write("    DEV_SIZE=$(expr $DEV_SIZE - 1)\n")
        disc_writer.write("\n")
        part_label_type = d.getVarFlag('UPDATABLE_PARTITIONS', 'type')
        disc_writer.write("    parted -s /dev/%s mklabel %s\n" % (device_name, part_label_type))

    mount = []
    for part in (d.getVar('UPDATABLE_PARTITIONS') or "").split():
        part_flags = d.getVarFlags('UPDATABLE_PARTITION_%s' % part)
        if 'offset' in part_flags:
            offset = number_in_sectors(part_flags.get( 'offset'), d)
            if offset < next_ofs:
                bb.warn("UPDATABLE_PARTITION_%s[offset]: %d < %d" % (part, offset, next_ofs))
                offset = next_ofs
        else:
            offset = next_ofs
        next_ofs = offset + 1
        size = number_in_sectors(part_flags.get('size'), d)
        disc_writer.write("    %s_FS_START=%d\n" % (part, sectors_to_KiB(offset, d)))
        if size == -1:
            disc_writer.write('    %s_FS_END=$DEV_SIZE\n' % part)
        else:
            disc_writer.write("    %s_FS_END=%d\n" % (part, sectors_to_KiB(offset + size, d)))
        disc_writer.write("    parted -s /dev/%s unit KiB mkpart primary ${%s_FS_START} ${%s_FS_END}\n" % (device_name, part, part))
        if 'filesystem' in part_flags and 'src' in part_flags and part_flags.get('src') == "none":
            fs = part_flags.get("filesystem")
            fs_create = part_flags.get("fs_create") or ""
            disc_writer.write("    mkfs -t %s %s /dev/%s%s%d\n" % (fs, fs_create, device_name, device_sep, part_no))
            if 'fs_tune' in part_flags:
                fs_tune = part_flags.get("fs_tune")
                disc_writer.write("    tune2fs %s /dev/%s%s%d\n" % (fs_tune, device_name, device_sep, part_no))
            mount.append(part)

        d.setVarFlag('UPDATABLE_PARTITION_%s' % part, 'part_no', part_no)
        d.setVarFlag('UPDATABLE_PARTITION_%s' % part, 'mntdev', "/dev/%s%s%d" % (device_name, device_sep, part_no))

        next_ofs += size
        part_no += 1
        disc_writer.write("\n")

    disc_writer.write("    parted /dev/%s print\n" % device_name)
    disc_writer.write("    \n")

    mntenv = []
    for part in (d.getVar('UPDATABLE_PARTITIONS') or "").split():
        part_flags = d.getVarFlags('UPDATABLE_PARTITION_%s' % part)
        mntdev = part_flags.get("mntdev")
        disc_writer.write('    PARTDEV_%s="%s"\n' % (part, mntdev))
        mntenv.append('PARTDEV_%s="%s"' % (part, mntdev))
        if part in mount:
            mountpoint = part_flags.get("mountpoint")
            disc_writer.write('    MNT_%s=${MNT_BASE}/root%s\n' % (part, mountpoint))
            mntenv.append('MNT_%s="${MNT_BASE}/root%s"' % (part, mountpoint))
            disc_writer.write('    mkdir -p ${MNT_%s}\n' % part)
            disc_writer.write('    mount %s ${MNT_%s}\n' % (mntdev, part))
    disc_writer.write("}\n\n")
    disc_writer.write('DEPLOY_VARS=\'%s\'\n\n' % " ".join(mntenv))

    mntenv = []
    disc_writer.write("prepare_update () {\n")
    disc_writer.write("    set -x\n")
    disc_writer.write("\n")
    disc_writer.write("    if [ ! -e /dev/%s ]\n" % device_name)
    disc_writer.write("    then\n")
    disc_writer.write('        logger -s "Cannot flash image on %s: /dev/%s not found"\n' % (wrt, device_name))
    disc_writer.write("        trigger_error\n")
    disc_writer.write("    fi\n")
    disc_writer.write("\n")
    for part in (d.getVar('UPDATABLE_PARTITIONS') or "").split():
        part_flags = d.getVarFlags('UPDATABLE_PARTITION_%s' % part)
        mntdev = part_flags.get("mntdev")
        disc_writer.write('    PARTDEV_%s="%s"\n' % (part, mntdev))
        mntenv.append('PARTDEV_%s="%s"' % (part, mntdev))
        if part in mount:
            mountpoint = part_flags.get("mountpoint")
            disc_writer.write('    MNT_%s=%s\n' % (part, mountpoint))
            mntenv.append('MNT_%s="%s"' % (part, mountpoint))
            disc_writer.write("    mount %s ${MNT_%s}\n" % (mntdev, part))
    disc_writer.write("}\n\n")
    disc_writer.write('UPDATE_VARS=\'%s\'\n\n' % " ".join(mntenv))

    slots_together = {}
    slots_primary = []
    for slot in (d.getVar('UPDATABLE_BUNDLE_SLOTS') or "").split():
        slot_flags = d.getVarFlags('UPDATABLE_SLOT_%s' % slot)
        if slot_flags and "together" not in slot_flags:
            slots_primary.append(slot)
            continue
        t = slot_flags.get("together")
        st = slots_together.get(t) or []
        st.append(slot)
        slots_together.update({t : st})

    for sp in slots_primary:
        disc_writer.write("write_%s () {\n" % sp)
        disc_writer.write("    set -x\n")
        st = slots_together.get(sp) or []
        st.insert(0, sp)
        for slot in (st):
            slot_flags = d.getVarFlags('UPDATABLE_SLOT_%s' % slot)
            dest = d.expand(slot_flags.get("dest"))
            if dest == "raw":
                if "offset" not in slot_flags:
                    bb.fatal("UPDATABLE_SLOT_%s[dest] = raw but UPDATABLE_SLOT_%s[offset] is missing" % (slot, slot))
                target_device_name = device_name
                if "device" in slot_flags:
                    target_device_name = slot_flags.get("device")
                for ofs in d.expand(slot_flags.get("offset")).split(";"):
                    ofs = int(ofs)
                    if "seek" in slot_flags:
                        ofs += int(d.expand(slot_flags.get("seek")))
                    disc_writer.write("    dd if=${BUNDLE_CONTAINER}/${%s} of=/dev/%s seek=%d skip=%d bs=512\n" % (slot, target_device_name, ofs, int(d.expand(slot_flags.get("skip")) or 0)))
            elif dest[:1] == "/":
                for part in (d.getVar('UPDATABLE_PARTITIONS') or "").split():
                    part_flags = d.getVarFlags('UPDATABLE_PARTITION_%s' % part)
                    if 'mountpoint' in part_flags and dest == part_flags.get('mountpoint'):
                        disc_writer.write("    cp -a ${BUNDLE_CONTAINER}/${%s} ${MNT_%s}\n" % (slot, part))
                        break
            elif dest == "partition":
                for part in (d.getVar('UPDATABLE_PARTITIONS') or "").split():
                    part_flags = d.getVarFlags('UPDATABLE_PARTITION_%s' % part)
                    if part_flags.get('src') == 'slot' and 'slot' in part_flags and slot == part_flags.get('slot'):
                        disc_writer.write("    blkdiscard %s\n" % part_flags.get("mntdev"))
                        disc_writer.write("    dd if=${BUNDLE_CONTAINER}/${%s} of=%s bs=1M\n" % (slot, part_flags.get("mntdev")))
                        break
            else:
                bb.fatal("Unknown UPDATABLE_SLOT_%s[dest]: '%s'" % (slot, dest))
        disc_writer.write("}\n\n")

    disc_writer.close()

    return 1

def all_root_dev_names (d):
    rc = []
    avail_root_devs = d.getVar("AVAIL_ROOT_DEVS", True).split(" ")
    for dev in avail_root_devs:
        devnm = "ROOT_DEV_NAME-" + dev
        rc.append(devnm + "='" + d.getVar(devnm, True) + "'")
    return " ".join(rc)

def do_write_disc_access (d):
    flash_mode = d.getVar("FLASH_MODE")
    if flash_mode == "update":
        write_disc_access(d.getVar("WANTED_ROOT_DEV"), d)
    elif flash_mode == "deploy":
        for dev in d.getVar("AVAIL_ROOT_DEVS", True).split(" "):
            write_disc_access(dev, d)
    else:
        bb.fatal("Unhandled value of FLASH_MODE: '%s' -- suggest stick on either 'update' or 'deploy', respectively" % flash_mode)

python do_configure() {
    do_write_disc_access(d)
}

do_compile () {
    set -x

    EXPECTED_CONTENT="${UPDATABLE_BUNDLE_SLOTS}"

    SANITIZED_SRC=""
    SANITIZED_SRC_S=""
    for u in ${SRC_URI}
    do
        f="${WORKDIR}/"$(echo "$u" | sed -e 's,file://,,g')
        test -f "$f" || continue
        SANITIZED_SRC="${SANITIZED_SRC}${SANITIZED_SRC_S}${f}"
        SANITIZED_SRC_S=" "
    done
    cp -a ${SANITIZED_SRC} ${B}

    SANITIZED_BLD=$(echo ${SANITIZED_SRC} | sed -e "s,${WORKDIR},${B},g")

    if test -z "${UPDATABLE_BUNDLE_SIGN_PUBKEY}"
    then
        BUNDLE_SIGN_PUBKEY=$(basename ${UPDATABLE_KEY_FILE} | sed -e 's,pem$,pub,')
        openssl rsa -pubout -in "${UPDATABLE_KEY_FILE}" > ${B}/${BUNDLE_SIGN_PUBKEY}
        UPDATABLE_BUNDLE_SIGN_PUBKEY=${libexecdir}/flash-device/${BUNDLE_SIGN_PUBKEY}
    fi

    sed -i -e "s,@ARGV0@,${SYSTEM_IMAGE_UPDATE_FLASH_COMMAND},g" \
        -e "s,@LIBEXEC[@],${SYSTEM_IMAGE_UPDATE_FLASH_LIBEXEC_DIR},g" -e "s,@WANTED_ROOT_DEV[@],${WANTED_ROOT_DEV},g" \
        -e "s,@SYSTEM_IMAGE_UPDATE_FLASH_DIR[@],${SYSTEM_IMAGE_UPDATE_FLASH_DIR},g" \
        -e "s,@SYSTEM_IMAGE_UPDATE_DEPLOY_DIR[@],${SYSTEM_IMAGE_UPDATE_DEPLOY_DIR},g" \
        -e "s/@MACHINE[@]/${MACHINE}/g" -e "s,@SIGN_ALGORITHM[@],${UPDATABLE_BUNDLE_SIGN_ALGORITHM},g" \
        -e "s,@SIGN_PUBKEY[@],${UPDATABLE_BUNDLE_SIGN_PUBKEY},g" -e "s/@FLASH_MODE[@]/${FLASH_MODE}/g" \
        -e "s,@NFS_FLASH[@],${NFS_FLASH},g" -e "s,@MANIFEST_NAME[@],${UPDATABLE_BUNDLE_MANIFEST},g" \
        -e "s,@BOOTABLE_ROOT_DEVS[@],${BOOTABLE_ROOT_DEVS},g" -e "s,@INTERNAL_ROOT_DEV[@],${INTERNAL_ROOT_DEV},g" \
        ${SANITIZED_BLD}
}

do_install () {
    set -x

    install -d ${D}${sysconfdir}/init.d
    install -d ${D}${libexecdir}/flash-device

    install -m 0755 ${B}/flash-device.sh ${D}${sysconfdir}/init.d/flash-device
    for dev in ${AVAIL_ROOT_DEVS}
    do
        test -f ${B}/init.${dev} || continue
        install -m 0644 ${B}/init.${dev} ${D}${libexecdir}/flash-device/init.${dev}
    done
    for f in ${B}/init.${MACHINE} ${B}/init.generic
    do
        test -f $f || continue
        install -m 0644 $f ${D}${libexecdir}/flash-device/init
        break
    done
    install -m 0644 ${B}/algorithms ${D}${libexecdir}/flash-device/algorithms

    if test -z "${UPDATABLE_BUNDLE_SIGN_PUBKEY}"
    then
        BUNDLE_SIGN_PUBKEY=$(basename ${UPDATABLE_KEY_FILE} | sed -e 's,pem$,pub,')
        install -m 0400 ${B}/${BUNDLE_SIGN_PUBKEY} ${D}${libexecdir}/flash-device/${BUNDLE_SIGN_PUBKEY}
    fi

    update-rc.d -r ${D} flash-device start 25 3 5 .
}

FILES_${PN} += "${libexecdir}/flash-device"
