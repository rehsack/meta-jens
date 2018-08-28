# Copyright (C) 2018 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Very fast, header only, C++ logging library."
HOMEPAGE = "https://github.com/gabime/spdlog"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=6e5242b8f24d08c5e948675102937cc9"
SECTION = "libs"

SRCREV = "560df2878ad308b27873b3cc5e810635d69cfad6"
BRANCH = "master"
SRC_URI = "git://github.com/gabime/spdlog.git;protocol=https;branch=${BRANCH}"

S = "${WORKDIR}/git"

inherit cmake
