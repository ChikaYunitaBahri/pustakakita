<?php
require_once __DIR__ . '/helpers.php';

$body = bacaBodyPost();
$email = strtolower(trim(ambilTeks($body, 'email')));
$password = ambilTeks($body, 'password');

if ($email === '' || $password === '') {
    kirim(422, false, 'Email dan password wajib diisi');
}

$db = koneksi();
$stmt = $db->prepare(
    'SELECT id, nama, email, password_hash FROM users WHERE email = ?'
);
$stmt->execute([$email]);
$user = $stmt->fetch();

// Pesan dibuat sama agar tidak membocorkan email mana yang terdaftar.
if (!$user || !password_verify($password, $user['password_hash'])) {
    kirim(401, false, 'Email atau password salah');
}

// Token sesi: yang disimpan di database hanya hash-nya.
$token = bin2hex(random_bytes(32));
$simpan = $db->prepare('UPDATE users SET token_hash = ? WHERE id = ?');
$simpan->execute([hash('sha256', $token), $user['id']]);

kirim(200, true, 'Login berhasil', [
    'nama' => $user['nama'],
    'email' => $user['email'],
    'token' => $token,
]);
