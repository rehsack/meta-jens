# Copyright (C) 2018 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Very fast, header only, C++ logging library."
HOMEPAGE = "https://github.com/gabime/spdlog"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=6e5242b8f24d08c5e948675102937cc9"
SECTION = "libs"

SRCREV = "b6b9d835c588c35227410a9830e7a4586f90777a"
BRANCH = "v1.x"
SRC_URI = "git://github.com/gabime/spdlog.git;protocol=https;branch=${BRANCH}"

S = "${WORKDIR}/git"

inherit cmake
