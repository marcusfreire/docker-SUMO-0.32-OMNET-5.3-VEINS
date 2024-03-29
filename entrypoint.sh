#!/bin/bash

# Sets script to fail if any command fails.
set -e

set_xauth() {
	echo xauth add $DISPLAY . $XAUTH
	touch ~/.Xauthority
	xauth add $DISPLAY . $XAUTH
}
# export XAUTH=$(xauth list | head -n 1 | cut -d ' ' -f5)

print_usage() {
echo "

Usage:	$0 COMMAND

XAPPS Container

Options:
  help		Print this help
  omnet		Run OMNeT++ IDE
"
}

case "$1" in
    help)
        print_usage
        ;;
    omnet)
	set_xauth
	/src/omnetpp-5.3/bin/omnetpp
        ;;
    xeyes)
	set_xauth
	xeyes
        ;;
    *)
        exec "$@"
esac