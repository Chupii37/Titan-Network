#!/bin/bash

# Menarik image Docker
docker pull nezha123/titan-edge

# Membuat direktori ~/.titanedge jika belum ada
mkdir -p ~/.titanedge

# Menjalankan kontainer dengan konfigurasi yang dimodifikasi (menghapus flag --network=host)
docker run -d -v ~/.titanedge:/root/.titanedge nezha123/titan-edge
