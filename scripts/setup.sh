#!/usr/bin/env bash
#
# setup.sh — автоматическая установка и настройка nginx со статической страницей
# Запуск: sudo bash scripts/setup.sh
# Целевая ОС: Ubuntu Server 22.04 LTS
#
set -euo pipefail

SITE_NAME="my-site"
SITE_ROOT="/var/www/${SITE_NAME}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $EUID -ne 0 ]]; then
    echo "Запустите скрипт с правами root (sudo bash scripts/setup.sh)" >&2
    exit 1
fi

echo "[1/6] Обновление пакетов и установка nginx..."
apt update -y
apt install -y nginx ufw

echo "[2/6] Размещение статической страницы..."
mkdir -p "${SITE_ROOT}"
cp "${REPO_ROOT}/site/index.html" "${SITE_ROOT}/index.html"
chown -R www-data:www-data "${SITE_ROOT}"

echo "[3/6] Настройка виртуального хоста..."
cp "${REPO_ROOT}/nginx/${SITE_NAME}.conf" "/etc/nginx/sites-available/${SITE_NAME}"
ln -sf "/etc/nginx/sites-available/${SITE_NAME}" "/etc/nginx/sites-enabled/${SITE_NAME}"
rm -f /etc/nginx/sites-enabled/default

echo "[4/6] Проверка конфигурации и перезагрузка nginx..."
nginx -t
systemctl reload nginx

echo "[5/6] Включение автозапуска и старт сервиса..."
systemctl enable nginx
systemctl start nginx

echo "[6/6] Настройка файрвола (ufw)..."
ufw allow OpenSSH
ufw allow 'Nginx HTTP'
ufw --force enable

echo ""
echo "Готово. Проверка:"
systemctl is-enabled nginx
curl -sI http://localhost | head -n 1
echo ""
echo "Статус ufw:"
ufw status verbose
