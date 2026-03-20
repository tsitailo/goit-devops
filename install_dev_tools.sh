#!/bin/bash

# tested on Ubuntu 24.04
# Кольори
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[✔] $1${NC}"; }
skip() { echo -e "${YELLOW}[~] $1 — вже встановлено${NC}"; }
err()  { echo -e "${RED}[✘] $1${NC}"; }

echo "======================================"
echo "  Встановлення інструментів розробника"
echo "======================================"

# ---------- 1. Docker ----------
if command -v docker &>/dev/null; then
    skip "Docker ($(docker --version))"
else
    echo "[*] Встановлення Docker..."
    sudo apt-get update -y
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        -o /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
        https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER"
    ok "Docker встановлено ($(docker --version))"
fi

# ---------- 2. Docker Compose ----------
if command -v docker-compose &>/dev/null || docker compose version &>/dev/null 2>&1; then
    skip "Docker Compose"
else
    echo "[*] Встановлення Docker Compose..."
    sudo apt-get install -y docker-compose-plugin
    ok "Docker Compose встановлено ($(docker compose version))"
fi

# ---------- 3. Python 3.9+ ----------
if python3 --version 2>/dev/null | grep -qP "3\.(9|[1-9][0-9])"; then
    skip "Python ($(python3 --version))"
else
    echo "[*] Встановлення Python..."
    sudo apt-get install -y python3 python3-pip python3-venv
    ok "Python встановлено ($(python3 --version))"
fi

# ---------- 4. Django ----------
if python3 -c "import django" &>/dev/null; then
    skip "Django ($(python3 -c 'import django; print(django.get_version())'))"
else
    echo "[*] Встановлення Django..."
    pip3 install django --break-system-packages
    ok "Django встановлено ($(python3 -c 'import django; print(django.get_version())'))"
fi

# ---------- Підсумок ----------
echo ""
echo "======================================"
echo -e "${GREEN}  Готово! Версії:${NC}"
echo "  $(docker --version)"
echo "  $(docker compose version)"
echo "  $(python3 --version)"
echo "  Django $(python3 -c 'import django; print(django.get_version())')"
echo "======================================"
echo -e "${YELLOW}Увага: щоб docker працював без sudo → виконай: newgrp docker${NC}"
