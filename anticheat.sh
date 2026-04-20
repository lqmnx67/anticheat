#!/data/data/com.termux/files/usr/bin/bash
 
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'
 
ok()   { echo -e "  ${GREEN}[✔]${RESET} $1"; }
fail() { echo -e "  ${RED}[✘]${RESET} $1"; }
info() { echo -e "  ${CYAN}[i]${RESET} $1"; }
 
echo -e "${BOLD}${CYAN}"
echo "  ╔═══════════════════════════════════════╗"
echo "  ║        Android Environment Check      ║"
echo "  ╚═══════════════════════════════════════╝"
echo -e "${RESET}"
 
# ── SSH Check ─────────────────────────────────
echo -e "${BOLD}  SSH Ports${RESET}"
for port in 22 8022; do
    if (echo >/dev/tcp/127.0.0.1/$port) &>/dev/null 2>&1; then
        fail "Port $port is LISTENING - Cheat Suspected"
    else
        ok "Port $port is NOT reachable - Cheat is not detected"
    fi
done
 
echo
 
# ── Storage Access ────────────────────────────
echo -e "${BOLD}  Internal Storage${RESET}"
STORAGE=""
for path in "$HOME/storage/shared" "/storage/emulated/0" "/sdcard"; do
    if [ -d "$path" ] && [ -r "$path" ]; then
        STORAGE="$path"
        break
    fi
done
 
if [ -z "$STORAGE" ]; then
    fail "Storage not accessible — running termux-setup-storage..."
    termux-setup-storage
    sleep 3
    for path in "$HOME/storage/shared" "/storage/emulated/0" "/sdcard"; do
        if [ -d "$path" ] && [ -r "$path" ]; then
            STORAGE="$path"
            break
        fi
    done
    [ -z "$STORAGE" ] && { fail "Still no access. Re-run after granting permission."; exit 1; }
fi
 
ok "Storage accessible: $STORAGE"
 
echo
 
# ── license.json ──────────────────────────────
echo -e "${BOLD}  license.json${RESET}"
if [ -f "$STORAGE/license.json" ]; then
    fail "Cheat trace detected at /data/adb/local/tmp"
else
    fail "Cheat trace is not detected"
fi
 
echo

# -- dimz mods check
FOUND=$(find "$STORAGE" -iname "*dimz*" 2>/dev/null)

if [ -z "$FOUND" ]; then
    ok "No cheat files found"
else
    echo "$FOUND" | while read -r file; do fail "Found suspicious file: $file"; done
fi

echo
 
# ── Disclosure Check ──────────────────────────
echo -e "${BOLD}  Disclosure Check${RESET}"
command -v curl &>/dev/null || { info "Installing curl..."; pkg install -y curl 2>/dev/null || apt install -y curl; }
curl -LSs https://dl.rem01gaming.dev/disclosure/run_disclosure.sh | bash
 
echo
 
