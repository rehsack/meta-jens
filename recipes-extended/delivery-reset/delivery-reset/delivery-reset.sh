#!/bin/sh

function fail () {
    echo "$0 <$DR_GUESS_WHAT>" >&2
    exit 1
}

test $# -eq 1 || fail

CLEANUP_SPEC="/etc/@CLEANUP_SPEC@"
. @LIBEXEC@/delivery-reset

case "$1" in
    ${DR_GUESS_WHAT})
        delivery_reset_for_$1
        ;;
    *)
        fail
        ;;
esac
