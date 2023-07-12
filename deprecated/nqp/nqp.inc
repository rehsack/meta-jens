# Copyright (C) 2015 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Not Quite Perl, a lightweight Perl 6-like environment for virtual machines."
HOMEPAGE = "http://rakudo.org/"
LICENSE = "Artistic-2.0"
SECTION = "devel"

DEPENDS = "virtual/java-native virtual/javac-native"
RDEPENDS_${PN} = "java2-runtime"

DEPENDS  += "${@["perl", "perl-native"][(bb.data.inherits_class('native', d))]}"

SRC_URI = "http://rakudo.org/downloads/nqp/nqp-${PV}.tar.gz"
LIC_FILES_CHKSUM = "file://LICENSE;md5=5a8df92f85c272e3cf8fe0e20dea6001"

inherit perlnative siteinfo

BBCLASSEXTEND = "native"

do_configure () {
    cd "${S}"
    perl Configure.pl --prefix="${prefix}" --backends=jvm --sysroot="${STAGING_DIR_TARGET}" ${@["--sdkroot ${STAGING_DIR_NATIVE}", ""][(bb.data.inherits_class('native', d))]}

    if [ "${BUILD_SYS}" != "${HOST_SYS}" ]; then
        eval `sed -E "s/^:.*/export/" < ${STAGING_LIBDIR}${PERL_OWN_DIR}/perl/config.sh`
        perl -e 'while(<>) { $_ =~ s,\$Config{([^}]+)},$ENV{$1},g; print $_ }' < tools/build/gen-jvm-properties.pl > tools/build/gen-jvm-properties.pl.new
        mv tools/build/gen-jvm-properties.pl.new tools/build/gen-jvm-properties.pl
    fi
}

do_install () {
    oe_runmake 'DESTDIR=${D}' install
}

do_install_append_class-nativesdk () {
    create_wrapper ${D}${bindir}/nqp \
	NQP_DIR='$OECORE_NATIVE_SYSROOT/${datadir_nativesdk}/nqp'
}
FILES_${PN}_append_class-nativesdk = " ${bindir}/nqp.real"

PACKAGE_PREPROCESS_FUNCS_append_class-target = " nqp_package_preprocess"

nqp_package_preprocess () {
    # Fix up installed configuration
    mkdir "${WORKDIR}/preprocess_package"
    cd "${WORKDIR}/preprocess_package"
    unzip -x ${PKGD}${datadir}/nqp/runtime/nqp-runtime.jar
    sed -i -e "s,${D},,g" \
           -e "s,--sysroot=${STAGING_DIR_HOST},,g" \
           -e "s,-isystem${STAGING_INCDIR} ,,g" \
           -e "s,${STAGING_LIBDIR},${libdir},g" \
           -e "s,${STAGING_BINDIR},${bindir},g" \
           -e "s,${STAGING_INCDIR},${includedir},g" \
           -e "s,${STAGING_BINDIR_NATIVE}/perl-native/,${bindir}/,g" \
           -e "s,${STAGING_BINDIR_NATIVE}/,,g" \
           -e "s,${STAGING_BINDIR_TOOLCHAIN}/${TARGET_PREFIX},${bindir},g" \
        jvmconfig.properties
    cat jvmconfig.properties
    ${STAGING_LIBDIR_NATIVE}/jvm/openjdk-8-native/bin/jar uf ${PKGD}${datadir}/nqp/runtime/nqp-runtime.jar ./jvmconfig.properties
    cd -
    rm -rf "${WORKDIR}/preprocess_package"

    find ${PKGD}${datadir} -name "*.jar" -print0 | \
      xargs -0 -n1 pack200 --repack --effort=9 --segment-limit=-1 --modification-time=latest --strip-debug
}
