# Copyright (C) 2018 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

require wine-common.inc

PACKAGECONFIG[win16] = "--enable-win16,--disable-win16,"
PACKAGECONFIG[win64] = "--with-wine64=${BASE_WORKDIR}/${BUILD_SYS}/${PN}-native/${EXTENDPE}${PV}-${PR}/build,--disable-win64,"

PACKAGECONFIG[alsa] = "--with-alsa,--without-alsa,alsa-lib"
# XXX Kernel module?
#PACKAGECONFIG[capi] = "--with-capi,--without-capi,capi"
PACKAGECONFIG[cms] = "--with-cms,--without-cms,lcms"
PACKAGECONFIG[cups] = "--with-cups,--without-cups,cups"
PACKAGECONFIG[curses] = "--with-curses,--without-curses,ncurses"
PACKAGECONFIG[dbus] = "--with-dbus,--without-dbus,dbus"
# --with-float-abi=soft|softfp|hard
PACKAGECONFIG[fontconfig] = "--with-fontconfig,--without-fontconfig,fontconfig"
PACKAGECONFIG[freetype] = "--with-freetype,--without-freetype,freetype"
PACKAGECONFIG[gettext] = "--with-gettext,--without-gettext,gettext"
PACKAGECONFIG[gettextpo] = "--with-gettextpo,--without-gettextpo,gettext"
PACKAGECONFIG[gssapi] = "--with-gssapi,--without-gssapi,gssapi"
# XXX
PACKAGECONFIG[gstreamer] = "--with-gstreamer,--without-gstreamer,gstreamer1.0 gstreamer1.0-plugins-base"
# XXX https://www.freedesktop.org/wiki/Software/hal/
PACKAGECONFIG[hal] = "--with-hal,--without-hal,hal"
PACKAGECONFIG[jpeg] = "--with-jpeg,--without-jpeg,jpeg"
PACKAGECONFIG[krb5] = "--with-krb5,--without-krb5,krb5"
PACKAGECONFIG[ldap] = "--with-ldap,--without-ldap,openldap"
# XXX
PACKAGECONFIG[mpg123] = "--with-mpg123,--without-mpg123,mpg123"
PACKAGECONFIG[netapi] = "--with-netapi,--without-netapi,samba"
PACKAGECONFIG[openal] = "--with-openal,--without-openal,openal-soft"
# XXX disabled in mesa
# PACKAGECONFIG[opencl] = "--with-opencl,--without-opencl,opencl"
PACKAGECONFIG[opengl] = "--with-opengl,--without-opengl,virtual/libgl"
PACKAGECONFIG[osmesa] = "--with-osmesa,--without-osmesa,virtual/libgl"
PACKAGECONFIG[oss] = "--with-oss,--without-oss,alsa-oss"
PACKAGECONFIG[pcap] = "--with-pcap,--without-pcap,libpcap"
PACKAGECONFIG[png] = "--with-png,--without-png,libpng"
# --with-pthread=yes|no
PACKAGECONFIG[pulse] = "--with-pulse,--without-pulse,pulseaudio"
# XXX PACKAGECONFIG[sane] = "--with-sane,--without-sane,sane"
# XXX PACKAGECONFIG[sdl] = "--with-sdl,--without-sdl,sdl"
PACKAGECONFIG[tiff] = "--with-tiff,--without-tiff,tiff"
PACKAGECONFIG[udev] = "--with-udev,--without-udev,udev"
# Kernel module ...
# XXX PACKAGECONFIG[v4l] = "--with-v4l,--without-v4l,v4l"
# XXX PACKAGECONFIG[vkd3d] = "--with-vkd3d,--without-vkd3d,vkd3d"
PACKAGECONFIG[vulkan] = "--with-vulkan,--without-vulkan,mesa vulkan"
# --with-pthread=yes|no
PACKAGECONFIG[x11] = "--with-x,--without-x,libx11 xorgproto libxt libxext"
PACKAGECONFIG[xcomposite] = "--with-xcomposite,--without-xcomposite,libx11 xorgproto libxt libxext libxrender"
PACKAGECONFIG[xcursor] = "--with-xcursor,--without-xcursor,libx11 xorgproto libxt libxext libxrender"
PACKAGECONFIG[xfixes] = "--with-xfixes,--without-xfixes,libx11 xorgproto libxt libxext libxrender"
#PACKAGECONFIG[xinerama] = "--with-xinerama,--without-xinerama,libx11 xorgproto libxt libxext libxrender"
PACKAGECONFIG[xinput] = "--with-xinput,--without-xinput,libx11 xorgproto libxt libxext libxrender"
PACKAGECONFIG[xinput2] = "--with-xinput2,--without-xinput2,libx11 xorgproto libxt libxext libxrender"
PACKAGECONFIG[xrandr] = "--with-xrandr,--without-xrandr,libx11 xorgproto libxt libxext libxrender"
PACKAGECONFIG[xrender] = "--with-xrender,--without-xrender,libx11 xorgproto libxt libxext libxrender"
PACKAGECONFIG[xshape] = "--with-xshape,--without-xshape,libx11 xorgproto libxt libxext libxrender"
PACKAGECONFIG[xshm] = "--with-xshm,--without-xshm,libx11 xorgproto libxt libxext libxrender"
#PACKAGECONFIG[xxf86vm] = "--with-xxf86vm,--without-xxf86vm,libx11 xorgproto libxt libxext libxrender"
PACKAGECONFIG[xml] = "--with-xml,--without-xml,libxml2"
PACKAGECONFIG[xslt] = "--with-xslt,--without-xslt,libxslt"
PACKAGECONFIG[zlib] = "--with-zlib,--without-zlib,zlib"

DEPENDS += "wine-native"

export ac_cv_prog_PKG_CONFIG="pkg-config"
EXTRA_OECONF_append = " --with-wine-tools=${BASE_WORKDIR}/${BUILD_SYS}/${PN}-native/${EXTENDPE}${PV}-${PR}/build"
