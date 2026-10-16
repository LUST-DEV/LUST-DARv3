#!/usr/bin/env bash

dns_lookup() {
  local domain=${1:-}
  if [[ -z $domain || ${#domain} -gt 253 || $domain == -* || ! $domain =~ ^[A-Za-z0-9._-]+$ ]]; then
    printf '%sNom invalide : indiquez un hote (ex. example.org), sans URL.%s\n' "$RED" "$RESET" >&2
    return 2
  fi
  printf '%s╭─ RÉSOLUTION DNS : %s ─────────────────╮%s\n' "$CYAN" "$domain" "$RESET"
  if command -v nslookup >/dev/null 2>&1; then
    nslookup "$domain"
  elif command -v getent >/dev/null 2>&1; then
    getent ahosts "$domain"
  else
    printf '%sAucun résolveur disponible. Termux : pkg install dnsutils%s\n' "$RED" "$RESET" >&2
    return 1
  fi
}
