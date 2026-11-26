# ERD PustakaKita

```mermaid
erDiagram
    users ||--o{ loans : "melakukan"
    books ||--o{ loans : "dipinjam dalam"

    users {
        int id PK
        string nama
        string email UK
        string password_hash
    }
    books {
        string id PK
        string judul
        string penulis
        string kategori
        string gambar "boleh kosong"
        int stok
    }
    loans {
        int id PK
        int user_id FK
        string book_id FK
        date tgl_pinjam
        date tgl_jatuh_tempo
        date tgl_kembali "boleh kosong"
        string status "dipinjam atau kembali"
    }
```

## Relasi

- Satu user dapat memiliki banyak peminjaman (1 ke N).
- Satu buku dapat tercatat di banyak peminjaman (1 ke N).

## Aturan Denda Keterlambatan

Denda dihitung per hari keterlambatan dari tabel `loans`. Nilai denda **tidak disimpan sebagai kolom**, tetapi dihitung dari kolom yang sudah ada, sehingga struktur ERD tidak berubah.

```
hari_terlambat = max(0, tgl_kembali - tgl_jatuh_tempo)      (dalam hari)
denda          = hari_terlambat x tarif_per_hari
```

Jika buku belum dikembalikan (`tgl_kembali` kosong), `tgl_kembali` diganti dengan tanggal hari ini.

| Parameter | Nilai | Keterangan |
|---|---|---|
| `tarif_per_hari` | **Rp 1.000** (usulan, menunggu konfirmasi tim) | Disimpan sebagai satu konstanta di aplikasi |
| Durasi pinjam | 7 hari (usulan) | `tgl_jatuh_tempo = tgl_pinjam + durasi pinjam` |
| Dikembalikan tepat waktu | denda = 0 | |

Contoh: jatuh tempo 10 Des, dikembalikan 14 Des, maka terlambat 4 hari dan denda = 4 x 1.000 = **Rp 4.000**.

## Penyimpanan Data: Tabel Mana di Mana

| Data | Penyimpanan | Alasan |
|---|---|---|
| `users` | **MySQL** (server) | Data akun harus aman dan dipakai bersama; password disimpan dalam bentuk hash (`password_hash`) |
| `books` | **MySQL** (server) | Sumber data utama katalog, termasuk `stok` |
| `loans` | **MySQL** (server) | Data transaksi peminjaman harus konsisten antar perangkat |
| Salinan `books` dan `loans` | **SQLite** (lokal) | Cache supaya katalog dan riwayat tetap bisa dibuka saat offline |
| Sesi login (id user, token) | **Hive** (lokal) | Key-value sederhana dan cepat |
| Buku favorit | **Hive** (lokal) | Data kecil per perangkat |
| Preferensi (filter kategori terakhir, dll.) | **Hive** (lokal) | Pengaturan ringan |

Alur: aplikasi mengambil data lewat API ke MySQL, menyimpan salinan ke SQLite untuk akses offline, dan memakai Hive untuk sesi serta preferensi.