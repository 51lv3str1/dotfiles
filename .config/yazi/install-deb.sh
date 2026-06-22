#!/usr/bin/env bash
# Instala un .deb con apt desde yazi. Recibe la ruta del .deb como $1.
set -u

file="$1"

clear
printf '\033[1m== Instalando paquete .deb ==\033[0m\n'
printf 'Archivo: %s\n\n' "$file"

sudo apt install -y "$file"
status=$?

printf '\n'
if [ "$status" -eq 0 ]; then
  printf '\033[32m✓ Instalación completada.\033[0m\n'
else
  printf '\033[31m✗ apt salió con código %s.\033[0m\n' "$status"
  printf 'Si fue por dependencias, probá: sudo apt --fix-broken install\n'
fi

printf '\nPresioná una tecla para volver a yazi...'
read -rsn1
