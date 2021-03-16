# Class for creating updatable-container bundles borrowed from meta-rauc
#
# Description:
#
# See updatable-images-base for documentation

LICENSE = "MIT"

PACKAGE_ARCH ?= "${MACHINE_ARCH}-${WANTED_ROOT_DEV}"

PACKAGES = ""
INHIBIT_DEFAULT_DEPS = "1"

UPDATABLE_IMAGE_FSTYPE ??= "${@(d.getVar('IMAGE_FSTYPES') or "").split()[0]}"
UPDATABLE_IMAGE_FSTYPE[doc] = "Specifies the default file name extension to expect for collecting image artifacts. Defaults to first element set in IMAGE_FSTYPES."

do_fetch[cleandirs] = "${S}"
do_patch[noexec] = "1"
do_compile[noexec] = "1"
do_install[noexec] = "1"
do_populate_sysroot[noexec] = "1"
do_package[noexec] = "1"
do_package_qa[noexec] = "1"
do_packagedata[noexec] = "1"
deltask do_package_write_ipk
deltask do_package_write_deb
deltask do_package_write_rpm

inherit updatable-images-base

S = "${WORKDIR}"
B = "${WORKDIR}/build"
BUNDLE_DIR = "${S}/bundle"

UPDATABLE_KEY_FILE ??= ""
UPDATABLE_KEY_FILE[doc] = "Specifies the path to the UPDATABLE key file used for signing."

DEPENDS = "squashfs-tools-native openssl-native"
# DEPENDS += "${@bb.utils.contains('UPDATABLE_CASYNC_BUNDLE', '1', 'virtual/fakeroot-native casync-native', '', d)}"

def _protect(alg, bundle_imgpath, d):
    # from bb import utils
    import os
    import hashlib
    from OpenSSL.crypto import (sign, verify)

    if alg == "size":
        return os.stat(bundle_imgpath).st_size
    else:
        return bb.utils._hasher(hashlib.new(alg), bundle_imgpath)

def write_manifest(d):
    import shutil
    import os

    machine = d.getVar('MACHINE')
    img_fstype = d.getVar('UPDATABLE_IMAGE_FSTYPE')
    bundle_path = d.expand("${BUNDLE_DIR}")
    manifest_name = d.expand("${UPDATABLE_BUNDLE_MANIFEST}")

    bb.utils.mkdirhier(bundle_path)
    try:
        manifest = open('%s/%s' % (bundle_path, manifest_name), 'w')
    except OSError:
        raise bb.build.FuncFailed('Unable to open %s' % manifest_name)

    manifest.write(d.expand('COMPATIBLE="${UPDATABLE_BUNDLE_COMPATIBLE}"\n'))
    manifest.write(d.expand('VERSION="${UPDATABLE_BUNDLE_VERSION}"\n'))
    manifest.write(d.expand('MIN_BL_VER="${UPDATABLE_BUNDLE_MIN_BOOTLOADER_VERSION}"\n'))
    manifest.write(d.expand('DESCRIPTION="${UPDATABLE_BUNDLE_DESCRIPTION}"\n'))
    manifest.write(d.expand('BUILD="${UPDATABLE_BUNDLE_BUILD}"\n'))
    manifest.write(d.expand('DEV="${UPDATABLE_BUNDLE_DEVELOPER_BUILD}"\n'))
    manifest.write(d.expand('MACHINE="${MACHINE}"\n'))

    ubs = []
    for slot in (d.getVar('UPDATABLE_BUNDLE_SLOTS') or "").split():
        slot_flags = d.getVarFlags('UPDATABLE_SLOT_%s' % slot)
        if slot_flags and "together" in slot_flags:
            continue
        ubs.append(slot)

    manifest.write(d.expand('CONTAINS="%s"\n' % " ".join(ubs)))

    slot_hooks = []

    for slot in (d.getVar('UPDATABLE_BUNDLE_SLOTS') or "").split():
        slot_flags = d.getVarFlags('UPDATABLE_SLOT_%s' % slot)
        if slot_flags and 'name' in slot_flags:
            slotname = slot_flags.get('name')
        else:
            slotname = slot

        if slot_flags and 'type' in slot_flags:
            imgtype = slot_flags.get('type')
        else:
            imgtype = 'image'

        if slot_flags and 'fstype' in slot_flags:
            img_fstype = slot_flags.get('fstype')

        if imgtype == 'image':
            if slot_flags and 'file' in slot_flags:
                imgsource = d.getVarFlag('UPDATABLE_SLOT_%s' % slot, 'file')
            else:
                imgsource = "%s-%s.%s" % (d.getVar('UPDATABLE_SLOT_%s' % slot), machine, img_fstype)
            imgname = os.path.basename(imgsource)
        elif imgtype == 'boot':
            if slot_flags and 'file' in slot_flags:
                imgsource = d.getVarFlag('UPDATABLE_SLOT_%s' % slot, 'file')
            elif slot_flags and 'files' in slot_flags:
                imgsource = d.getVarFlag('UPDATABLE_SLOT_%s' % slot, 'files').split()
            imgname = os.path.basename(imgsource)
        elif imgtype == 'file':
            if slot_flags and 'file' in slot_flags:
                imgsource = d.getVarFlag('UPDATABLE_SLOT_%s' % slot, 'file')
            elif slot_flags and 'files' in slot_flags:
                imgsource = d.getVarFlag('UPDATABLE_SLOT_%s' % slot, 'files').split()
            imgname = os.path.basename(imgsource)
        else:
            raise bb.build.FuncFailed('Unknown image type: %s' % imgtype)

        if isinstance(imgsource, str):
            if slot_flags and 'rename' in slot_flags:
                imgname = os.path.basename(d.expand(slot_flags.get('rename')))

            bundle_imgpath = "%s/%s" % (bundle_path, imgname)
            # Set or update symlinks to image files
            if os.path.lexists(bundle_imgpath):
                bb.utils.remove(bundle_imgpath)
            bb.note("adding image to bundle dir: '%s'" % imgname)
            shutil.copy(d.expand("${DEPLOY_DIR_IMAGE}/%s") % imgsource, bundle_imgpath)
            if not os.path.exists(bundle_imgpath):
                raise bb.build.FuncFailed('Failed copying ${DEPLOY_DIR_IMAGE}/%s to %s' % (imgsource, bundle_imgpath))
            manifest.write("%s=\"%s\"\n" % (slot, imgname))
        elif isinstance(imgsource, list):
            for imgsrc in imgsource:
                imgname = os.path.basename(imgsrc)
                bundle_imgpath = "%s/%s" % (bundle_path, imgname)
                # Set or update symlinks to image files
                if os.path.lexists(bundle_imgpath):
                    bb.utils.remove(bundle_imgpath)
                bb.note("adding image to bundle dir: '%s'" % imgname)
                shutil.copy(d.expand("${DEPLOY_DIR_IMAGE}/%s") % imgsrc, bundle_imgpath)
                if not os.path.exists(bundle_imgpath):
                    raise bb.build.FuncFailed('Failed copying ${DEPLOY_DIR_IMAGE}/%s to %s' % (imgsrc, bundle_imgpath))
            manifest.write("%s=\"{%s}\"\n" % (slot, ",".join(imgsource)))
        else:
            bb.fatal("Unexpected type for 'imgsource': %s" % type(imgsource))

        if slot_flags and 'condition' in slot_flags:
            manifest.write("%s_CONDITION='%s'\n" % (slot, slot_flags.get('condition')))

        if slot_flags and 'hook' in slot_flags:
            slot_hook = slot_flags.get('hook')
            manifest.write('%s_HOOK="%s"\n' % (slot, slot_hook))
            slot_hooks.append(slot_hook)

    manifest.write(d.expand('OVERLAY_SHADOWS="${OVERLAY_SHADOWS}"\n'))
    manifest.write(d.expand('ROOT_DEV_NAME="${ROOT_DEV_NAME}"\n'))
    manifest.write(d.expand('ROOT_DEV_SEP="${ROOT_DEV_SEP}"\n'))
    manifest.write(d.expand('ROOT_DEV_TYPE="${ROOT_DEV_TYPE}"\n'))
    manifest.write(d.expand('WANTED_ROOT_DEV="${WANTED_ROOT_DEV}"\n'))
    manifest.write("\n")

    hooks_flags = d.getVarFlags('UPDATABLE_BUNDLE_HOOKS')
    manifest.write('TRIGGER="%s"\n' % (hooks_flags.get("trigger") or ""))
    hooks_triggers = (hooks_flags.get("trigger") or "").split()
    for trigger in hooks_triggers:
        d.setVar("TRIGGER_%s" % trigger, "")

    for hook in (d.getVar("UPDATABLE_BUNDLE_HOOKS") or "").split():
        hook_flags = d.getVarFlags('UPDATABLE_BUNDLE_HOOK_%s' % hook)
        if "trigger" not in hook_flags and hook not in slot_hooks:
            bb.warn("Hook %s defined, but not triggered" % hook)
        else:
            for t in (hook_flags.get("trigger") or "").split():
                if t not in hooks_triggers:
                    bb.error("Trigger %s of hook %s not in UPDATABLE_BUNDLE_HOOKS[trigger]" % (t, hook))
                elif d.getVar("TRIGGER_%s" % t) == "":
                    d.appendVar("TRIGGER_%s" % t, hook)
                else:
                    d.appendVar("TRIGGER_%s" % t, " %s" % hook)
        hook_type = hook_flags.get("type")
        if hook_type == "inline":
            hook_code = d.expand(hook_flags.get("code"))
            manifest.write("HOOK_%s='%s'\n" % (hook, hook_code))
        elif hook_type == "script":
            hook_script = hook_flags.get("src")
            manifest.write("HOOK_%s='${BUNDLE_CONTAINER}/%s'\n" % (hook, hook_script))
        else:
            bb.fatal("Unhandled value of UPDATABLE_BUNDLE_HOOK_%s[type]: '%s' -- suggest stick on either 'inline' or 'script', respectively" % (hook, hook_type))

    for trigger in hooks_triggers:
        if d.getVar("TRIGGER_%s" % trigger) != "":
            manifest.write(d.expand('TRIGGER_%s="${TRIGGER_%s}"\n' % (trigger, trigger)))

    manifest.close()

python do_configure() {
    import shutil
    import os
    import stat

    write_manifest(d)

    for hook in (d.getVar("UPDATABLE_BUNDLE_HOOKS") or "").split():
        hook_flags = d.getVarFlags('UPDATABLE_BUNDLE_HOOK_%s' % hook)
        if hook_flags and 'src' in hook_flags:
            hf = hook_flags.get('src')
            dsthook = d.expand("${BUNDLE_DIR}/%s" % hf)
            searchpath = d.expand("${DEPLOY_DIR_IMAGE}/%s") % hf
            if os.path.isfile(searchpath):
                bb.note("adding hook file from deploy dir to bundle dir: '%s'" % file)
                shutil.copy(searchpath, destpath)
                st = os.stat(dsthook)
                os.chmod(dsthook, st.st_mode | stat.S_IEXEC)
                continue

            searchpath = d.expand("${WORKDIR}/%s") % file
            if os.path.isfile(searchpath):
                bb.note("adding hook file from workdir to bundle dir: '%s'" % file)
                shutil.copy(searchpath, dsthook)
                st = os.stat(dsthook)
                os.chmod(dsthook, st.st_mode | stat.S_IEXEC)
                continue

            bb.error("hook file '%s' neither found in workdir nor in deploy dir!" % file)

    for file in (d.getVar('UPDATABLE_BUNDLE_EXTRA_FILES') or "").split():
        searchpath = d.expand("${DEPLOY_DIR_IMAGE}/%s") % file
        destpath = d.expand("${BUNDLE_DIR}/%s") % file
        if os.path.isfile(searchpath):
            bb.note("adding extra file from deploy dir to bundle dir: '%s'" % file)
            shutil.copy(searchpath, destpath)
            continue

        searchpath = d.expand("${WORKDIR}/%s") % file
        if os.path.isfile(searchpath):
            bb.note("adding extra file from workdir to bundle dir: '%s'" % file)
            shutil.copy(searchpath, destpath)
            continue

        bb.error("extra file '%s' neither found in workdir nor in deploy dir!" % file)
}

BUNDLE_BASENAME ??= "${PN}"
BUNDLE_BASENAME[doc] = "Specifies desired output base name of generated bundle."
BUNDLE_NAME ??= "${BUNDLE_BASENAME}-${WANTED_ROOT_DEV}-${MACHINE}-${UPDATABLE_BUNDLE_VERSION}-${DATETIME}"
BUNDLE_NAME[doc] = "Specifies desired full output name of generated bundle."
# Don't include the DATETIME variable in the sstate package sigantures
BUNDLE_NAME[vardepsexclude] = "DATETIME"
BUNDLE_LINK_NAME ??= "${BUNDLE_BASENAME}-${WANTED_ROOT_DEV}-${MACHINE}"
BUNDLE_EXTENSION ??= ".sfsuc"
BUNDLE_EXTENSION[doc] = "Specifies desired custom filename extension of generated bundle"

BUNDLE_DEPLOY_DIR = "${WORKDIR}/deploy-${BUNDLE_BASENAME}-image-complete"

BUNDLE_CMD_squashfs = "mksquashfs ${BUNDLE_DIR} ${BUNDLE_DEPLOY_DIR}/${BUNDLE_NAME}${BUNDLE_EXTENSION} ${EXTRA_BUNDLECMD} -root-owned -noappend"
BUNDLE_CMD_squashfs-xz = "mksquashfs ${BUNDLE_DIR} ${BUNDLE_DEPLOY_DIR}/${BUNDLE_NAME}${BUNDLE_EXTENSION} ${EXTRA_BUNDLECMD} -root-owned -noappend -comp xz"
BUNDLE_CMD_squashfs-lzo = "mksquashfs ${BUNDLE_DIR} ${BUNDLE_DEPLOY_DIR}/${BUNDLE_NAME}${BUNDLE_EXTENSION} ${EXTRA_BUNDLECMD} -root-owned -noappend -comp lzo"
BUNDLE_CMD_squashfs-lz4 = "mksquashfs ${BUNDLE_DIR} ${BUNDLE_DEPLOY_DIR}/${BUNDLE_NAME}${BUNDLE_EXTENSION} ${EXTRA_BUNDLECMD} -root-owned -noappend -comp lz4"

do_bundle() {
	if [ -z "${UPDATABLE_KEY_FILE}" ]; then
		bbfatal "'UPDATABLE_KEY_FILE' not set. Please set to a valid key file location."
	fi

	mkdir -p ${BUNDLE_DEPLOY_DIR}
	${BUNDLE_CMD_squashfs}
        openssl dgst -${UPDATABLE_BUNDLE_SIGN_ALGORITHM} -sign ${UPDATABLE_KEY_FILE} -out ${BUNDLE_DEPLOY_DIR}/${BUNDLE_NAME}${BUNDLE_EXTENSION}.sign -binary ${BUNDLE_DEPLOY_DIR}/${BUNDLE_NAME}${BUNDLE_EXTENSION}
        cat ${BUNDLE_DEPLOY_DIR}/${BUNDLE_NAME}${BUNDLE_EXTENSION}.sign >> ${BUNDLE_DEPLOY_DIR}/${BUNDLE_NAME}${BUNDLE_EXTENSION}
}
do_bundle[dirs] = "${B}"
do_bundle[cleandirs] = "${B}"

addtask bundle after do_configure before do_build

inherit deploy

do_deploy() {
	install -d ${DEPLOYDIR}
	install -m 0644 ${BUNDLE_DEPLOY_DIR}/${BUNDLE_NAME}${BUNDLE_EXTENSION} ${DEPLOYDIR}/${BUNDLE_NAME}${BUNDLE_EXTENSION}
	ln -sf ${BUNDLE_NAME}${BUNDLE_EXTENSION} ${DEPLOYDIR}/${BUNDLE_LINK_NAME}${BUNDLE_EXTENSION}
	install -m 0644 ${BUNDLE_DEPLOY_DIR}/${BUNDLE_NAME}${BUNDLE_EXTENSION}.sign ${DEPLOYDIR}/${BUNDLE_NAME}${BUNDLE_EXTENSION}.sign
	ln -sf ${BUNDLE_NAME}${BUNDLE_EXTENSION}.sign ${DEPLOYDIR}/${BUNDLE_LINK_NAME}${BUNDLE_EXTENSION}.sign
	install -m 644 ${BUNDLE_DIR}/${UPDATABLE_BUNDLE_MANIFEST} ${DEPLOYDIR}/.${BUNDLE_NAME}-${UPDATABLE_BUNDLE_MANIFEST}
	ln -sf .${BUNDLE_NAME}-${UPDATABLE_BUNDLE_MANIFEST} ${DEPLOYDIR}/.${BUNDLE_LINK_NAME}-${UPDATABLE_BUNDLE_MANIFEST}
}

addtask deploy after do_bundle before do_build

do_deploy[cleandirs] = "${DEPLOYDIR}"
