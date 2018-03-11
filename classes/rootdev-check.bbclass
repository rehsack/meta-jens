# Allow checking of required and conflicting WANTED_ROOT_DEV
#
python () {
    avail_root_devs = (d.getVar('AVAIL_ROOT_DEVS', True) or "").split()
    compat_root_devs = (d.getVar('COMPAT_ROOT_DEVS', True) or "").split()
    if not compat_root_devs:
        compat_root_devs = avail_root_devs

    wanted_root_dev = d.getVar('WANTED_ROOT_DEV', True)
    if not wanted_root_dev in compat_root_devs:
        raise bb.parse.SkipPackage("WANTED_ROOT_DEV ('%s') not in compatible root_devs %s" %(wanted_root_dev, compat_root_devs))

    conflict_root_devs = (d.getVar('CONFLICT_ROOT_DEVS', True) or "").split()
    if conflict_root_devs:
        if wanted_root_dev in conflict_root_devs:
            raise bb.parse.SkipPackage("WANTED_ROOT_DEV ('%s') conflicts with %s" %(wanted_root_dev, conflict_root_devs))
}
