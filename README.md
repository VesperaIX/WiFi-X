<h1 align="center">WiFi X</h1>

<p align="center">
    <img src="https://github.com/VesperaIX/WiFiX/blob/main/src/img.png">
</p>

<br>

# Simple Wi-Fi Attack Script

## Deskripsi
Script ini adalah tool sederhana untuk melakukan **ARP spoofing** berbasis deteksi interface jaringan secara **otomatis**. Script ini akan melakukan pemindaian jaringan untuk mendapatkan daftar perangkat yang terhubung, lalu pengguna dapat memilih target untuk diserang. Setelah memilih target, script ini akan menjalankan serangan ARP spoofing dan mem-forward paket dari target ke gateway, memungkinkan Anda untuk memantau atau memodifikasi lalu lintas jaringan.

**Note:** Script ini ditujukan hanya untuk keperluan edukasi dan pengujian penetrasi pada jaringan yang Anda miliki atau yang telah Anda dapatkan izin untuk melakukannya. Menggunakan tool ini pada jaringan tanpa izin merupakan pelanggaran hukum.

## Fitur
- Pemindaian jaringan untuk menemukan perangkat yang terhubung.
- Menampilkan daftar perangkat yang ditemukan di jaringan.
- Melakukan ARP spoofing terhadap perangkat yang dipilih.
- Memulihkan tabel ARP saat serangan dihentikan (dengan Ctrl+C).

## Persyaratan Sistem
Sebelum menjalankan script ini, pastikan sistem Anda memiliki dependensi berikut:
- Sistem Operasi berbasis Linux
- Interface jaringan `eth0` (atau ganti dengan interface lain jika diperlukan)
- Paket-paket berikut:
  - `arp-scan`
  - `nmap`
  - `arpspoof`
  - `arping`

## Instalasi

### 1. Install Dependencies
Jalankan perintah berikut untuk menginstal semua dependensi yang diperlukan:

```bash
sudo apt update
sudo apt install arp-scan nmap dsniff arping
```

# Disclamer
Saya tidak bertangung jawab atas tindakan pengguna, gunakan dengan bijak
<br>
<br>
Regards,
<br>
VesperaIX

**Author:**
- **VesperaIX**
- **Discord: VesperaIX**
