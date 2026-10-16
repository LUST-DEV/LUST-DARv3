#!/usr/bin/env bash

network_info() {
  if ! command -v ip >/dev/null 2>&1; then
    printf '%sLa commande ip est absente. Installez iproute2 (Termux : pkg install iproute2).%s\n' "$RED" "$RESET" >&2
    return 1
  fi
  printf '%s╭─ INTERFACES RÉSEAU ────────────────────────╮%s\n' "$BLUE" "$RESET"
  if ip -brief address 2>/dev/null; then :; else ip address show 2>/dev/null || { printf 'Impossible de lire les interfaces réseau.\n' >&2; return 1; }; fi
  printf '\n%s╭─ TABLE DE ROUTAGE ─────────────────────────╮%s\n' "$CYAN" "$RESET"
  ip route show 2>/dev/null || ip -6 route show 2>/dev/null || { printf 'Routes indisponibles.\n' >&2; return 1; }
}
