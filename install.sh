#!/bin/sh

if [ $(uname) != 'Linux' ]; then
    echo "This script is designed for linux only, sorry!"
    exit 1
fi

set -e

RED='[1;31m'
GREEN='[1;32m'
YELLOW='[1;33m'
CYAN='[1;36m'
BOLD='[1m'
RESET='[0m'

printf '\n%b' $CYAN && cat << 'EOF'
      ▪  ▄▄
▪     ██ ██▌
 ▄█▀▄ ▐█·▐█·
▐█▌.▐▌▐█▌.▀
 ▀█▄▀▪▀▀▀ ▀
EOF
printf '%b' $RESET

if !command -v cargo >/dev/null 2>&1; then
    printf '%berror:%b can not find %bcargo%b in your $PATH, please ensure it is correctly installed\n' $RED $RESET $BOLD $RESET
    exit 1
fi

if command -v sudo >/dev/null 2>&1; then
    PRIV_ESC='sudo'
elif command -v doas >/dev/null 2>&1; then
    PRIV_ESC='doas'
else
    printf '%berror:%b can not find %bsudo%b or %bdoas%b in your $PATH, one of these is required\n' $RED $RESET $BOLD $RESET $BOLD $RESET
    exit 1
fi

cd "$(dirname "$0")"
printf '%bSTEP 1:%b %bbuilding the binary%b (this may take a few minutes)\n\n' $GREEN $RESET $BOLD $RESET
cargo build --release
command -v strip >/dev/null 2>&1 && strip -s ./target/release/oi

printf '\n%bSTEP 2:%b %bcopying files%b (elevated privileges are required)\n\n' $GREEN $RESET $BOLD $RESET
$PRIV_ESC install -Dvm755 ./target/release/oi /usr/local/bin/oi
$PRIV_ESC install -Dvm644 ./etc/completions/_oi /usr/share/zsh/site-functions/_oi
$PRIV_ESC install -Dvm644 ./etc/completions/oi.bash /usr/share/bash-completion/completions/oi
$PRIV_ESC install -Dvm644 ./etc/completions/oi.fish /usr/share/fish/vendor_completions.d/oi.fish

printf '\n%bDONE:%b %bthanks for testing! %b<3%b (this repo is no longer needed and can be deleted)\n' $GREEN $RESET $BOLD $RED $RESET
