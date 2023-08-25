#!/bin/bash

[ -z "$1" ] && echo "Error: parameter missing! Usage: $0 <host_to_query> [VPN_IP_to_ping | -v]" 1>&2 && exit 1

[ -e "/etc/default/pmdns" ] && . /etc/default/pmdns
WGET="/usr/bin/wget"
SELF="`basename $0`"
WGETLOG="/tmp/${SELF}.log"

[ -n "$2" -a "$2" != "-v" ] && ping -q -c1 -t5 -w5 "$2" > /dev/null && echo "$2" && exit 0
if [ "$2" == "-v" ]; then
	echo "$WGET -v4O- --content-on-error \"${PMDNS_URL}?pass=${PMDNS_PASS}&name=$1\""
	NEWIP=`$WGET -v4O- --content-on-error "${PMDNS_URL}?pass=${PMDNS_PASS}&name=$1"`
	RET=$?
	echo "$NEWIP"
	[ $RET -ne 0 ] && echo "*** wget returned $RET" && exit $RET
else
	NEWIP=`$WGET -nv -4O- --content-on-error "${PMDNS_URL}?pass=${PMDNS_PASS}&name=$1" 2> "$WGETLOG"`
	RET=$?
	[ $RET -ne 0 ] && echo "`tr '\n' ' ' < "$WGETLOG"` # $NEWIP # err$RET" | logger -t $SELF -p daemon.warning && exit $RET
fi

echo "$NEWIP"
grep -qw "${NEWIP}.*$1" /etc/hosts && exit 0
[ "$2" == "-v" ] && echo "New IP $NEWIP for $1" || logger -t $SELF -p daemon.notice "New IP $NEWIP for $1"
grep -qw "$1" /etc/hosts && sed -i "s/.*\b$1\b/$NEWIP $1/" /etc/hosts || echo "$NEWIP $1" >> /etc/hosts
killall -HUP dnsmasq openvpn 2> /dev/null
