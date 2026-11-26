<?php
require_once __DIR__ . '/config.php';

// Detail error masuk ke log server, tidak dikirim ke aplikasi.
ini_set('display_errors', '0');

set_exception_handler(function (Throwable $e): void {
    error_log($e->__toString());
    kirim(500, false, 'Terjadi kesalahan pada server');
});

function kirim(int $status, bool $sukses, string $pesan, ?array $data = null): void
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    $isi = ['sukses' => $sukses, 'pesan' => $pesan];
    if ($data !== null) {
        $isi['data'] = $data;
    }
    echo json_encode($isi);
    exit;
}

function bacaBodyPost(): array
{
    if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
        kirim(405, false, 'Gunakan metode POST');
    }
    $body = json_decode(file_get_contents('php://input'), true);
    if (!is_array($body)) {
        kirim(400, false, 'Body harus berupa JSON');
    }
    return $body;
}

function ambilTeks(array $body, string $kunci): string
{
    $nilai = $body[$kunci] ?? '';
    return is_string($nilai) ? $nilai : '';
}

function koneksi(): PDO
{
    return new PDO(
        'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4',
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]
    );
}
