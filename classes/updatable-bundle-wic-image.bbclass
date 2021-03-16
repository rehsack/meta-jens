# Description:
#
# See updatable-images-base for documentation

def updatable_rootfs_slot(d):
    updatable_rootfs_slot = d.expand("${UPDATABLE_BUNDLE_IMAGES}").split()[0]
    if not updatable_rootfs_slot:
        bb.fatal("suitable UPDATABLE_BUNDLE_IMAGES is missing")

    return updatable_rootfs_slot

def updatable_rootfs_image(d):
    updatable_rootfs_slot = d.expand("${UPDATABLE_ROOTFS_SLOT}") or updatable_rootfs_slot(d)
    updatable_rootfs_image = d.expand("${UPDATABLE_IMAGE_%s}" % updatable_rootfs_slot)
    if not updatable_rootfs_image:
        bb.fatal("suitable UPDATABLE_IMAGE_%s is missing" % updatable_rootfs_slot)

    return updatable_rootfs_image

USUAL_IMAGE_FSTYPES := "${IMAGE_FSTYPES}"
IMAGE_FSTYPES := "wic"
UPDATABLE_ROOTFS_SLOT ??= "${@updatable_rootfs_slot(d)}"
UPDATABLE_ROOTFS_IMAGE ??= "${@updatable_rootfs_image(d)}"

# IMAGE SIZE in MB - 8G == 8192
UPDATABLE_IMAGE_SIZE ??= "8192"

inherit updatable-images-base updatable-image

WKS_FULL_PATH := "${B}/${UPDATABLE_BUNDLE_WKS_FILENAME}"

def number_in_megabytes (n, d):
    u = {"M":1, "m":1, "G":1024, "g":1024}
    if not n[-1:].isdigit():
        unit = n[-1:]
        n = n[:-1]
        if unit not in u:
            bb.warn("Unknown unit for size: %s" % unit)
            mb = 1
        else:
            mb = u[unit]

        n = int(n) * mb
    else:
        n = int(n)

    return n

python do_write_wks_file () {
    import shutil

    build_path = d.expand("${B}")
    bb.utils.mkdirhier(build_path)

    wks_filename = "%s" % (d.getVar("UPDATABLE_BUNDLE_WKS_FILENAME"))
    try:
        wks_file_writer = open('%s/%s' % (build_path, wks_filename), 'w')
    except OSError:
        raise bb.build.FuncFailed('Unable to open %s' % wks_filename)

    wic_image_size = int(d.getVar("UPDATABLE_IMAGE_SIZE"))
    image_fstype_now = d.getVar("IMAGE_FSTYPES")
    image_fstype_usually = d.getVar("USUAL_IMAGE_FSTYPES")

    part_content = {}
    for slot in (d.getVar('UPDATABLE_BUNDLE_SLOTS') or "").split():
        slot_flags = d.getVarFlags('UPDATABLE_SLOT_%s' % slot)

        if "file" not in slot_flags:
            bb.fatal("UPDATABLE_SLOT_%s[file] is missing" % slot)
        src = d.expand(slot_flags.get("file"))

        if "dest" not in slot_flags:
            bb.fatal("UPDATABLE_SLOT_%s[dest] is missing" % slot)
        dest = d.expand(slot_flags.get("dest"))
        if dest == "raw":
            if "device" in slot_flags:
                bb.fatal("UPDATABLE_SLOT_%s[device] is set but won't be supported for wic" % slot)
            if "offset" not in slot_flags:
                bb.fatal("UPDATABLE_SLOT_%s[dest] = raw but UPDATABLE_SLOT_%s[offset] is missing" % (slot, slot))
            slot_inc = 0
            slot_x = ""
            for ofs in d.expand(slot_flags.get("offset")).split(";"):
                ofs = int(ofs)
                if "seek" in slot_flags:
                    ofs += int(d.expand(slot_flags.get("seek")))
                if slot_inc > 0:
                    slot_x = "_%d" % slot_inc
                wks_file_writer.write('part %s%s --source rawcopy --sourceparams="file=%s" --no-table --align %d\n' % (slot, slot_x, src, ofs / 2))
                slot_inc = slot_inc + 1
        elif dest[:1] == "/":
            for part in (d.getVar('UPDATABLE_PARTITIONS') or "").split():
                part_flags = d.getVarFlags('UPDATABLE_PARTITION_%s' % part)
                if 'mountpoint' in part_flags and dest == part_flags.get('mountpoint'):
                    pc = part_content.get(part) or []
                    pc.append(src)
                    part_content.update({part : pc})
                    break
        elif dest == "partition":
            for part in (d.getVar('UPDATABLE_PARTITIONS') or "").split():
                part_flags = d.getVarFlags('UPDATABLE_PARTITION_%s' % part)
                if part_flags.get('src') == 'slot' and 'slot' in part_flags and slot == part_flags.get('slot'):
                    bb.note("Replacing '%s' with '%s' in '%s'" % (image_fstype_now, image_fstype_usually, src))
                    src = src.replace(image_fstype_now, image_fstype_usually)
                    bb.note("Setting src of '%s' to '%s'" % (part, src))
                    part_content.update({part : src})
                    break
        else:
            bb.fatal("Unknown UPDATABLE_SLOT_%s[dest]: '%s'" % (slot, dest))
    wks_file_writer.write("\n")

    for part in (d.getVar('UPDATABLE_PARTITIONS') or "").split():
        part_flags = d.getVarFlags('UPDATABLE_PARTITION_%s' % part)
        part_src = part_flags.get('src')
        if 'mountpoint' in part_flags:
            mountpoint = part_flags.get('mountpoint')
        else:
            mountpoint = "/" + part.lower

        part_line = "part %s" % (mountpoint)

        if part_src == "none":
            slot_src = " ".join(part_content.get(part) or [])
            if slot_src != "":
                part_line = part_line + ' --source updatable-extra-partition --sourceparams="files=%s"' % slot_src
            if mountpoint == "/boot":
                part_line = part_line + ' --active'
        elif part_src == "slot":
            slot_src = part_content.get(part)
            part_line = part_line + ' --source rawcopy --sourceparams="file=%s"' % slot_src
        else:
            bb.fatal("Unsupported UPDATABLE_PART_%s[src]: '%s'" % (part, part_src))

        if 'filesystem' in part_flags:
            part_line = part_line + " --fstype %s" % d.expand(part_flags.get('filesystem'))

        if 'fs_label' in part_flags:
            part_line = part_line + " --label %s" % d.expand(part_flags.get('fs_label'))

        # if 'fs_create' in part_flags or 'fs_tune' in part_flags:
        # if 'fs_create' in part_flags:
            # fs_create = (part_flags.get('fs_create') or "")
            # fs_tune = (part_flags.get('fs_tune') or "")
            # part_line = part_line + " --mkfs-extraopts '%s'" % " ".join((fs_create, fs_tune))
            # part_line = part_line + " --mkfs-extraopts '%s'" % fs_create

        if 'size' in part_flags:
            part_size = part_flags.get('size')
            if part_size == "-1":
                part_mb = wic_image_size
            else:
                part_mb = number_in_megabytes(part_size, d)
                wic_image_size = wic_image_size - part_mb
            part_line = part_line + " --fixed-size %s" % part_mb

        wks_file_writer.write("%s\n" % part_line)

    wks_file_writer.write("\n")

    bootloader_type = d.getVar('UPDATABLE_BUNDLE_BOOTLOADER_TYPE', False) or "msdos"
    wks_file_writer.write("bootloader --ptable %s\n" % bootloader_type)
}

python () {
    if d.getVar('USING_WIC'):
        wks_target_u = d.getVar('UPDATABLE_BUNDLE_WKS_FILENAME', False)
        wks_target = d.expand(wks_target_u)
        base, ext = os.path.splitext(wks_target)
        if ext == '.in' and os.path.exists(wks_file):
            bb.build.addtask('do_write_wks_file', 'do_write_wks_template', 'do_image', d)
        else:
            bb.build.addtask('do_write_wks_file', 'do_image_wic', 'do_image', d)

        d.setVar('IMAGE_FSTYPES', 'wic')
}

do_write_wks_file[vardeps] += "${UPDATABLE_BUNDLE_WKS_FILENAME}"

do_build[depends] += " \
        updatable-updater-bundle:do_deploy \
"
