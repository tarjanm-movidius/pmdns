#!/bin/bash

[ -e "/etc/default/pmdns" ] && . /etc/default/pmdns

[ "$1" == "-f" ] && shift && rm "$IPFILE"
OLDIP=`cat $IPFILE` 2>/dev/null
WGET="/usr/bin/wget"
SELF="`basename $0`"
WGETLOG="/tmp/${SELF}.log"

while true; do
	MYIP=`$WGET -qO- ifconfig.me 2>/dev/null` || ( sleep $PMDNS_DLY; continue )
	if [ -n "$MYIP" -a "$MYIP" != "$OLDIP" ] && ! grep -q '[^0-9.]' <<< "$MYIP"; then
		if [ "$1" == "-d" ]; then
			$WGET -nv -4O- --content-on-error "${PMDNS_URL}?name=${PMDNS_HOST}&newip=${MYIP}" &> "$WGETLOG"
			if [ $? -ne 0 ]; then
				tr '\n' ' ' < "$WGETLOG" | logger -t $SELF -p daemon.warning
			else
				logger -t $SELF -p daemon.notice "New IP: $MYIP"
				OLDIP=$MYIP
				echo "$OLDIP" > "$IPFILE"
			fi
		else
			echo "$WGET -v4O- --content-on-error \"${PMDNS_URL}?name=${PMDNS_HOST}&newip=${MYIP}\""
			$WGET -v4O- --content-on-error "${PMDNS_URL}?name=${PMDNS_HOST}&newip=${MYIP}" > "$WGETLOG"
			RET=$?
			cat "$WGETLOG"
			[ $RET -eq 0 ] && OLDIP=$MYIP && echo "$OLDIP" > "$IPFILE" || echo "*** wget returned $RET"
			exit $RET
		fi
	fi
	sleep $PMDNS_DLY
done
