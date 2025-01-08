#!/bin/bash

# Menampilkan pesan setelah logo dengan warna cyan
echo -e "\033[36mShowing ANIANI!!!\033[0m" 

# Menampilkan logo tanpa menyimpan file, langsung dari URL
echo -e "\033[32mMenampilkan logo...\033[0m"
wget -qO- https://raw.githubusercontent.com/Chupii37/Chupii-Node/refs/heads/main/Logo.sh | bash 

# Variabel untuk Titan Agent
AGENT_URL="https://pcdn.titannet.io/test4/bin/agent-linux.zip"
INSTALL_DIR="/opt/titanagent"
AGENT_ZIP="agent-linux.zip"
WORKING_DIR="/opt/titanagent"
SERVER_URL="https://test4-api.titannet.io"

# Langkah 1: Meminta Pengguna Memasukkan Kunci Titan
echo -e "\033[36mMasukkan kunci Titan Anda: \033[0m"
read -r KEY  # Menerima input kunci dari pengguna

# Memastikan kunci tidak kosong
if [ -z "$KEY" ]; then
  echo -e "\033[31mKunci Titan tidak boleh kosong. Skrip dibatalkan.\033[0m"
  exit 1
fi

# Langkah 2: Memperbarui daftar paket
echo -e "\033[34mMemperbarui daftar paket...\033[0m"
sudo apt update
if [ $? -ne 0 ]; then
  echo -e "\033[31mGagal memperbarui daftar paket.\033[0m"
  exit 1
fi

# Langkah 3: Menginstal snapd jika belum terinstal
echo -e "\033[34mMemeriksa dan menginstal snapd...\033[0m"
sudo apt install -y snapd
if [ $? -ne 0 ]; then
  echo -e "\033[31mGagal menginstal snapd.\033[0m"
  exit 1
fi

# Langkah 4: Mengaktifkan dan menjalankan snapd.socket
echo -e "\033[34mMengaktifkan snapd.socket...\033[0m"
sudo systemctl enable --now snapd.socket
if [ $? -ne 0 ]; then
  echo -e "\033[31mGagal mengaktifkan snapd.socket.\033[0m"
  exit 1
fi

# Langkah 5: Menginstal Multipass menggunakan Snap
echo -e "\033[34mMenginstal Multipass...\033[0m"
sudo snap install multipass
if [ $? -ne 0 ]; then
  echo -e "\033[31mGagal menginstal Multipass.\033[0m"
  exit 1
fi

# Verifikasi Instalasi Multipass
echo -e "\033[34mMemverifikasi instalasi Multipass...\033[0m"
multipass --version
if [ $? -ne 0 ]; then
  echo -e "\033[31mMultipass tidak terinstal dengan benar.\033[0m"
  exit 1
fi

# Langkah 6: Memeriksa Koneksi Internet
echo -e "\033[34mMemeriksa koneksi jaringan...\033[0m"
ping -c 4 google.com > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo -e "\033[31mKoneksi internet gagal. Periksa jaringan Anda.\033[0m"
  exit 1
fi

# Langkah 7: Mengunduh File Titan Agent
echo -e "\033[34mMengunduh Titan Agent...\033[0m"
mkdir -p $INSTALL_DIR  # Membuat direktori jika belum ada

# Cek apakah file sudah ada
if [ ! -f "$INSTALL_DIR/$AGENT_ZIP" ]; then
  wget -O $INSTALL_DIR/$AGENT_ZIP $AGENT_URL
  if [ $? -ne 0 ]; then
    echo -e "\033[31mUnduhan gagal. Periksa koneksi jaringan atau URL.\033[0m"
    exit 1
  fi
else
  echo -e "\033[32mFile agent-linux.zip sudah ada, melanjutkan ekstraksi...\033[0m"
fi

# Langkah 8: Ekstrak File Titan Agent
echo -e "\033[34mMenyiapkan direktori dan mengekstrak file...\033[0m"
# Memastikan unzip terinstal
if ! command -v unzip &> /dev/null; then
  echo -e "\033[31mPerintah unzip tidak ditemukan. Menginstal unzip...\033[0m"
  sudo apt install -y unzip
fi

unzip $INSTALL_DIR/$AGENT_ZIP -d $INSTALL_DIR
if [ $? -ne 0 ]; then
  echo -e "\033[31mEkstraksi gagal. Pastikan unzip terinstal.\033[0m"
  exit 1
fi

# Langkah 9: Memberikan Izin Eksekusi pada File Titan Agent
echo -e "\033[34mMenambahkan izin eksekusi pada file agent...\033[0m"
chmod +x $INSTALL_DIR/agent
if [ $? -ne 0 ]; then
  echo -e "\033[31mGagal memberikan izin eksekusi. Jalankan dengan sudo.\033[0m"
  exit 1
fi

# Langkah 10: Menjalankan Titan Agent
echo -e "\033[34mMenjalankan Titan Agent...\033[0m"
$INSTALL_DIR/agent --working-dir=$WORKING_DIR --server-url=$SERVER_URL --key=$KEY
if [ $? -ne 0 ]; then
  echo -e "\033[31mTitan Agent gagal dijalankan.\033[0m"
  exit 1
fi

# Langkah 11: Menyeting Titan Agent sebagai Layanan Sistem (Systemd)
echo -e "\033[34mMenyeting Titan Agent sebagai layanan sistem...\033[0m"
cat <<EOF | sudo tee /etc/systemd/system/titan-agent.service
[Unit]
Description=Titan Agent Service
After=network.target

[Service]
ExecStart=$INSTALL_DIR/agent --working-dir=$WORKING_DIR --server-url=$SERVER_URL --key=$KEY
WorkingDirectory=$INSTALL_DIR
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF
echo -e "\033[32mUnit systemd untuk Titan Agent telah dibuat.\033[0m"

# Langkah 12: Mengaktifkan dan Memulai Layanan Titan Agent
echo -e "\033[34mMengaktifkan dan memulai layanan Titan Agent...\033[0m"
sudo systemctl enable titan-agent.service
sudo systemctl start titan-agent.service
if [ $? -ne 0 ]; then
  echo -e "\033[31mGagal memulai layanan Titan Agent.\033[0m"
  exit 1
fi

# Langkah 13: Memeriksa Status Layanan Titan Agent
echo -e "\033[34mMemeriksa status layanan Titan Agent...\033[0m"
sudo systemctl status titan-agent.service

# Langkah 14: Menampilkan log real-time dari Titan Agent
echo -e "\033[32mMemulai untuk memantau log real-time Titan Agent...\033[0m"
sudo journalctl -u titan-agent -f --no-hostname -o cat

# Menampilkan pesan sukses
echo -e "\033[32mTitan Agent telah berhasil diinstal dan dijalankan sebagai layanan!\033[0m"
echo -e "\033[32mMultipass juga telah terinstal.\033[0m"
echo -e "\033[33mProses instalasi selesai.\033[0m"
