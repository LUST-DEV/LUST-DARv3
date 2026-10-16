#!/usr/bin/env bash

scan_target() {
  local target=${1:-} port_list=${2:-} port status
  local -a ports=()
  if [[ -z $target || -z $port_list ]]; then
    printf 'Usage : lust-dar scan <hote-explicite> <ports-exacts-separes-par-virgule>\n' >&2
    return 2
  fi
  if [[ ${#target} -gt 253 || ! $target =~ ^[A-Za-z0-9][A-Za-z0-9.-]*$ || $target == *..* ]]; then
    printf '%sHote invalide. Indiquez un nom DNS ou une adresse IPv4, sans URL.%s\n' "$RED" "$RESET" >&2
    return 2
  fi
  if [[ ! $port_list =~ ^[0-9]+(,[0-9]+){0,31}$ ]]; then
    printf '%sListe invalide : indiquez de 1 a 32 ports numeriques separes par des virgules.%s\n' "$RED" "$RESET" >&2
    return 2
  fi
  IFS=',' read -r -a ports <<< "$port_list"
  for port in "${ports[@]}"; do
    if ((${#port} > 5)) || ((10#$port < 1 || 10#$port > 65535)); then
      printf '%sPort hors plage : %s (valeurs admises : 1-65535).%s\n' "$RED" "$port" "$RESET" >&2
      return 2
    fi
  done
  if ! command -v timeout >/dev/null 2>&1; then
    printf '%sCommande timeout absente. Termux/Linux : installez coreutils.%s\n' "$RED" "$RESET" >&2
    return 1
  fi

  printf '%s╭─ VERIFICATION TCP CIBLEE ──────────────────╮%s\n' "$CYAN" "$RESET"
  printf 'Cible : %s | Ports demandes : %s | Delai par port : 2 s\n' "$target" "$port_list"
  printf '%sUtilisez uniquement sur un systeme dont vous avez l autorisation.%s\n\n' "$YELLOW" "$RESET"
  for port in "${ports[@]}"; do
    # La commande est volontairement littérale; la cible et le port arrivent en paramètres séparés.
    # shellcheck disable=SC2016
    if timeout 2 bash -c 'exec 3<>"/dev/tcp/$1/$2"' _ "$target" "$port" >/dev/null 2>&1; then
      status='OUVERT'
      printf '  %s[+] %s:%s %s%s\n' "$GREEN" "$target" "$port" "$status" "$RESET"
    else
      status='non accessible (ferme, filtre ou delai depasse)'
      printf '  %s[-] %s:%s %s%s\n' "$DIM" "$target" "$port" "$status" "$RESET"
    fi
  done
  printf '\nUn port non accessible ne distingue pas un refus d un filtrage ou d un delai depasse.\n'
}
