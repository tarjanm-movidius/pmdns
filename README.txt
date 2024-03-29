Poor man's DNS

A dirty hack really to get two machines on dynamic IP addresses be able to talk to each other.

The idea is:
 * setting up some free web hosting, have ip.php installed there, that
   - stores and retrieves IPs
   - ...in txt files, when I grow up I'll put them in a DB
   - ?name=my_lil_host queries the IP of my_lil_host that's returned as plain text
   - ?name=my_lil_host&newip=1.2.3.4 updates the stored IP of my_lil_host
   - ?pass=secret password needed for all operations. Change it in php and /etc/default/pmdns
 * SRV side (of which we want to know the IP of) has pmdns.sh running as a service
   - config in /etc/default/pmdns
   - waits PMDNS_DLY seconds
   - queries its real world IP address (works in behind-router-with-port-forwarding situation)
   - if it has changed compared to what's stored in IPFILE, update PMDNS_HOST record of PMDNS_URL
   - repeat
   - started by /etc/init.d/pmdns.sh with -d (daemonize) cmdline param. Without that script is in
     debug mode with verbose prints & exit after send. Use -f to send IP even if it matches saved
 * CLNT side (with which we want to connect to SRV) calls pmdnsq.sh from a cron job
   - ...is pretty arbitrary, in its present state it's used for a VPN connection
   - config in /etc/default/pmdns (can be the same as SRV)
   - 1st cmdline param is the host name to query
   - 2nd (optional) param is a VPN IP to ping, and exit immediately if it responds (or -v for
     verbose prints)
   - if we didn't or couldn't ping, query host IP from PMDNS_URL
   - check if response is different from what's in /etc/hosts, update as necessary
   - send SIGHUP to dnsmasq and openvpn
