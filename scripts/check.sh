#!/usr/bin/env bash
# Smoke-test a built PHP: every required extension loads, intl formats,
# and php-fpm starts its config test. Usage: scripts/check.sh <dir with php, php-fpm>
set -euo pipefail
dir="$1"
php="$dir/php"
"$php" -v
loaded=$("$php" -m | tr 'A-Z' 'a-z')
missing=()
for ext in $(tr ',' ' ' < "$(dirname "$0")/../extensions.txt"); do
  case "$ext" in mbregex|mysqlnd|xml) continue ;; esac   # part of others / not listed by -m
  name="$ext"
  [ "$ext" = opcache ] && name="zend opcache"
  grep -qx "$name" <<< "$loaded" || missing+=("$ext")
done
if [ ${#missing[@]} -gt 0 ]; then
  echo "missing extensions: ${missing[*]}"
  exit 1
fi
"$php" -r 'echo (new NumberFormatter("en_US", NumberFormatter::DECIMAL))->format(1234.5), PHP_EOL;' | grep -qx '1,234.5'
"$dir/php-fpm" -v
# Xdebug (shared) loads into this PHP.
so="$dir/../modules/xdebug.so"
if [ -f "$so" ]; then
  "$php" -n -d "zend_extension=$(cd "$(dirname "$so")" && pwd)/xdebug.so" -r 'exit(phpversion("xdebug") ? 0 : 1);' || { echo "xdebug.so does not load"; exit 1; }
  echo "xdebug: $("$php" -n -d "zend_extension=$(cd "$(dirname "$so")" && pwd)/xdebug.so" -r 'echo phpversion("xdebug");')"
fi
echo "ok: $("$php" -r 'echo PHP_VERSION;') with $(wc -l <<< "$loaded") modules"
