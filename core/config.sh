#!/usr/bin/env bash
# shellcheck disable=SC2034
# Palette uniquement visuelle : aucun fichier utilisateur n'est exécuté.
if [[ -t 1 && -z ${NO_COLOR:-} ]]; then
  RESET=$'\033[0m'; BOLD=$'\033[1m'; DIM=$'\033[2m'
  CYAN=$'\033[38;5;51m'; AQUA=$'\033[38;5;87m'; BLUE=$'\033[38;5;39m'
  PURPLE=$'\033[38;5;141m'; GREEN=$'\033[38;5;82m'; YELLOW=$'\033[38;5;220m'
  RED=$'\033[38;5;203m'; WHITE=$'\033[38;5;255m'
else
  RESET=''; BOLD=''; DIM=''; CYAN=''; AQUA=''; BLUE=''; PURPLE=''; GREEN=''; YELLOW=''; RED=''; WHITE=''
fi
APP_NAME='LUST-DAR'
APP_VERSION='5.0.0-dev'
