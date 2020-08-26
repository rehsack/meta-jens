FLASH_MODE = "deploy"

RDEPENDS_${PN} = "\
	parted \
	e2fsprogs \
	e2fsprogs-tune2fs \
"

NFS_FLASH = "#"
