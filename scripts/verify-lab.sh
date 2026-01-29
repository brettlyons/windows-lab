#!/usr/bin/env bash
# verify-lab.sh - Test Windows AD Lab VM status and connectivity
# Usage: ./verify-lab.sh [--full]

set -uo pipefail
# Note: not using -e so tests can continue after failures

# Configuration
PROXMOX_HOST="${PROXMOX_HOST:-smallbox-0}"
PROXMOX_USER="${PROXMOX_USER:-root}"
DC01_VMID=120
CLIENT01_VMID=121
CLIENT02_VMID=122
DC01_IP="172.16.1.10"
DOMAIN="home.lab"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
info() { echo -e "[ -- ] $1"; }

# Test functions
test_vm_status() {
    local vmid=$1
    local name=$2
    local status
    status=$(ssh "${PROXMOX_USER}@${PROXMOX_HOST}" "qm status $vmid" 2>/dev/null | awk '{print $2}')
    if [[ "$status" == "running" ]]; then
        pass "$name (VMID $vmid) is running"
        return 0
    elif [[ "$status" == "stopped" ]]; then
        warn "$name (VMID $vmid) is stopped"
        return 1
    else
        fail "$name (VMID $vmid) status unknown: $status"
        return 1
    fi
}

test_qemu_agent() {
    local vmid=$1
    local name=$2
    if ssh "${PROXMOX_USER}@${PROXMOX_HOST}" "qm guest cmd $vmid ping" &>/dev/null; then
        pass "$name QEMU guest agent responding"
        return 0
    else
        warn "$name QEMU guest agent not responding (VM may still be booting)"
        return 1
    fi
}

test_ping() {
    local ip=$1
    local name=$2
    if ping -c 1 -W 2 "$ip" &>/dev/null; then
        pass "$name ($ip) is reachable"
        return 0
    else
        fail "$name ($ip) is not reachable"
        return 1
    fi
}

test_dns() {
    local server=$1
    local query=$2
    if nslookup "$query" "$server" &>/dev/null; then
        pass "DNS query for $query via $server succeeded"
        return 0
    else
        fail "DNS query for $query via $server failed"
        return 1
    fi
}

test_ad_ports() {
    local ip=$1
    local name=$2
    local ports=(53 88 135 389 445 636)
    local failed=0

    for port in "${ports[@]}"; do
        if timeout 2 bash -c "echo >/dev/tcp/$ip/$port" 2>/dev/null; then
            pass "$name port $port ($(port_name $port)) open"
        else
            fail "$name port $port ($(port_name $port)) closed"
            ((failed++))
        fi
    done
    return $failed
}

port_name() {
    case $1 in
        53) echo "DNS" ;;
        88) echo "Kerberos" ;;
        135) echo "RPC" ;;
        389) echo "LDAP" ;;
        445) echo "SMB" ;;
        636) echo "LDAPS" ;;
        *) echo "Unknown" ;;
    esac
}

get_vm_ip() {
    local vmid=$1
    ssh "${PROXMOX_USER}@${PROXMOX_HOST}" \
        "qm guest cmd $vmid network-get-interfaces 2>/dev/null" | \
        jq -r '.[].["ip-addresses"][]? | select(.["ip-address-type"]=="ipv4") | .["ip-address"]' 2>/dev/null | \
        grep -v "^127\." | head -1
}

# Main
echo "=========================================="
echo "Windows AD Lab Verification"
echo "=========================================="
echo ""

echo "--- Proxmox VM Status ---"
test_vm_status $DC01_VMID "DC01"
dc01_up=$?
test_vm_status $CLIENT01_VMID "CLIENT01"
test_vm_status $CLIENT02_VMID "CLIENT02"
echo ""

if [[ $dc01_up -eq 0 ]]; then
    echo "--- DC01 Guest Agent ---"
    test_qemu_agent $DC01_VMID "DC01"
    echo ""

    echo "--- DC01 Network ---"
    dc01_detected_ip=$(get_vm_ip $DC01_VMID 2>/dev/null || echo "")
    if [[ -n "$dc01_detected_ip" ]]; then
        info "DC01 detected IP: $dc01_detected_ip"
    fi
    test_ping "$DC01_IP" "DC01"
    dc01_reachable=$?
    echo ""

    if [[ "$1" == "--full" ]] 2>/dev/null && [[ $dc01_reachable -eq 0 ]]; then
        echo "--- AD Services (DC01) ---"
        test_ad_ports "$DC01_IP" "DC01"
        echo ""

        echo "--- DNS Resolution ---"
        test_dns "$DC01_IP" "$DOMAIN"
        echo ""
    fi
fi

echo "=========================================="
echo "Verification complete"
echo "=========================================="
