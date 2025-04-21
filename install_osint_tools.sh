#!/data/data/com.termux/files/usr/bin/bash
# Установка всех OSINT-инструментов для Termux

set -e

echo "[*] Обновляем Termux..."
pkg update -y && pkg upgrade -y

echo "[*] Устанавливаем системные утилиты..."
pkg install -y python git curl wget jq whois dnsutils openssl ffmpeg \
                whiptail nmap grep

echo "[*] Устанавливаем Python‑библиотеки и OSINT‑инструменты..."
pip install --upgrade pip
pip install sherlock twint instaloader theHarvester phonenumbers \
            snscrape googler sublist3r yt-dlp

echo "[+] Установка завершена!"
