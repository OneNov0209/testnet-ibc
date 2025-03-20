#!/bin/bash

# Pastikan script berjalan sebagai root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Harap jalankan sebagai root!"
    exit 1
fi

echo "🚀 Mengunduh dan menginstal Og Validator..."

# Update sistem
apt update && apt upgrade -y

# Install dependensi dasar
apt install -y wget curl jq git

# Pastikan direktori /root ada (terutama jika dijalankan di user lain)
mkdir -p /root

# Download skrip validator
wget -O /root/0g_validator.sh http://file.onenov.xyz/files/0g_validator.sh

# Cek apakah file berhasil diunduh
if [ ! -f /root/0g_validator.sh ]; then
    echo "❌ Gagal mengunduh skrip validator!"
    exit 1
fi

# Beri izin eksekusi pada skrip
chmod +x /root/0g_validator.sh

# Jalankan skrip validator
bash /root/0g_validator.sh

echo "✅ Instalasi selesai! Cek status dengan: systemctl status validator"
