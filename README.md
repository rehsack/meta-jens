OpenEmbedded/Yocto Project layer for MultiFS support & Jens Development
========================================================================

This layer provides support for updatable multifs images for use with
Yocto Project build systems.

This layer requires few additions to poky maintained in

URI: https://github.com/rehsack/poky
branch: master
revision: HEAD

URI: https://github.com/meta-cpan/meta-cpan
branch: master
revision: HEAD

Contributing:
-------------

You can submit Pull Requests via GitHub.

Please refer to:
https://wiki.yoctoproject.org/wiki/Contribution_Guidelines#General_Information

for some useful guidelines to be followed when submitting patches.

Usage instructions
------------------

bblayers.conf:

At the very moment, meta-jens and the scripts within, rely on following:

    BBPATH = "${TOPDIR}"
    BSPDIR := "${@os.path.abspath(os.path.dirname(d.getVar('FILE', True)) + '/../..')}"
    
    BBLAYERS = "\
    ${BSPDIR}/sources/meta-cpan \
    ${BSPDIR}/sources/meta-jens \
    "

local.conf:

Beside some common tweaks, permissions must be tuned to allow proper
operations, overlay-mounts etc.

    FILESYSTEM_PERMS_TABLES = "files/multifs-perms.txt"
