DUMMYPROVIDES_PACKAGES_append = "\
    ${@bb.utils.contains("PACKAGECONFIG", 'network-setup', ' ifupdown ', '', d )} \
    ${@bb.utils.contains("PACKAGECONFIG", 'no-procps', '', 'procps', d )} \
"
