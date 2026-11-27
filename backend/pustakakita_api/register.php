<?php
require_once __DIR__ . '/helpers.php';

$body = bacaBodyPost();
$nama = trim(ambilTeks($body, 'nama'));
$email = strtolower(trim(ambilTeks($body, 'email')));
$password = ambilTeks($body, 'password');

$panjangNama = mb_strlen($nama, 'UTF-8');
if ($panjangNama < 3 || $panjangNama > 100) {
    kirim(422, false, 'Nama harus 3-100 karakter');
}
if (strlen($email) > 190 || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    kirim(422, false, 'Format email tidak valid');
}
if (mb_strlen($password, 'UTF-8') < 8) {
    kirim(422, false, 'Password minimal 8 karakter');
}
// bcrypt hanya memakai 72 byte pertama.
if (strlen($password) > 72) {
    kirim(422, false, 'Password terlalu panjang');
}

$db = koneksi();
try {
    $stmt = $db->prepare(
        'INSERT INTO users (nama, email, password_hash) VALUES (?, ?, ?)'
    );
    $stmt->execute([$nama, $email, password_hash($password, PASSWORD_DEFAULT)]);
} catch (PDOException $e) {
    // 1062 = duplikat pada kolom UNIQUE (email).
    if (($e->errorInfo[1] ?? 0) === 1062) {
        kirim(409, false, 'Email sudah terdaftar');
    }
    throw $e;
}

kirim(201, true, 'Registrasi berhasil', ['nama' => $nama, 'email' => $email]);
