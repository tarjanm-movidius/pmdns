#!/bin/bash

[ "$1" == "stop" ] && killall pmdns.sh && exit 0
/usr/bin/pmdns.sh -d &

exit 0
