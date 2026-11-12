#!/bin/bash
#
# verify-connectivity.bash
# Aruba OSPF routing, MariaDB and nftables lab
#
# Runs the VM-side checks for the lab:
#   1. Lab interface address (from the Aruba DHCP server)
#   2. Routing table
#   3. Ping to the local gateway and to a peer in another VLAN
#   4. SSH port reachability on the gateway and the peer
#   5. HTTP response and MariaDB port (3306) on the web/database VM
#
# Usage:  ./verify-connectivity.bash [gateway_ip] [peer_ip] [web_ip] [interface]
# Example: ./verify-connectivity.bash 172.16.22.1 172.16.33.15 172.16.11.11
#
# If no interface is given, the interface holding a 172.16.x.x address is used.
#
# Written and tested by: Avraham Abel

GATEWAY="${1:-172.16.22.1}"
PEER="${2:-172.16.33.15}"
WEB="${3:-172.16.11.11}"
IFACE="${4:-$(ip -4 -o addr show | awk '/inet 172\.16\./ {print $2; exit}')}"

# Welcome splash screen
printf '#%.0s' {1..50}; printf '\n'
printf '  Aruba OSPF Lab - Connectivity Check\n'
printf '#%.0s' {1..50}; printf '\n\n'

PASS=0
FAIL=0

check() {
    # check "description" command...
    local desc="$1"; shift
    if "$@" >/dev/null 2>&1; then
        printf '[ OK ]   %s\n' "$desc"
        PASS=$((PASS + 1))
    else
        printf '[FAIL]   %s\n' "$desc" >&2
        FAIL=$((FAIL + 1))
    fi
}

# 1. Interface address
printf '== Interface %s ==\n' "${IFACE:-<none found>}"
if [ -n "$IFACE" ]; then
    ip -brief addr show "$IFACE"
else
    printf 'No interface with a 172.16.x.x address found\n' >&2
fi
printf '\n'

# 2. Routing table
printf '== Routes ==\n'
ip route
printf '\n'

# 3-5. Reachability
printf '== Checks ==\n'
check "A lab interface has a 172.16.x.x address" \
    bash -c "ip -4 addr show | grep -q 'inet 172\.16\.'"
check "Ping gateway $GATEWAY" ping -c 2 -W 2 "$GATEWAY"
check "Ping peer $PEER (other VLAN)" ping -c 2 -W 2 "$PEER"
check "SSH port 22 open on $GATEWAY" timeout 3 bash -c "</dev/tcp/$GATEWAY/22"
check "SSH port 22 open on $PEER" timeout 3 bash -c "</dev/tcp/$PEER/22"
check "MariaDB port 3306 open on $WEB" timeout 3 bash -c "</dev/tcp/$WEB/3306"

if command -v curl >/dev/null 2>&1; then
    check "HTTP 200 from http://$WEB" \
        bash -c "[ \"\$(curl -s -o /dev/null -m 5 -w '%{http_code}' http://$WEB)\" = 200 ]"
else
    printf '[SKIP]   curl not installed, web check skipped\n'
fi

printf '\nResult: %d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
