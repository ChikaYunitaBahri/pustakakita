<?php
require_once __DIR__ . '/helpers.php';

$body = bacaBodyPost();
$token = ambilTeks($body, 'token');

if ($token === '') {
    kirim(422, false, 'Token wajib diisi');
}

$stmt = koneksi()->prepare(
    'UPDATE users SET token_hash = NULL WHERE token_hash = ?'
);
$stmt->execute([hash('sha256', $token)]);

if ($stmt->rowCount() !== 1) {
    kirim(401, false, 'Sesi tidak ditemukan');
}

kirim(200, true, 'Logout berhasil');
