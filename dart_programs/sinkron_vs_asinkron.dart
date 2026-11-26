// ignore_for_file: avoid_print

void sinkron() {
  print('1. Sinkron: mulai');
  final sw = Stopwatch()..start();
  while (sw.elapsed.inSeconds < 5) {} // menahan program 5 detik
  print('2. Sinkron: selesai setelah 5 detik');
}

Future<void> asinkron() async {
  print('3. Async: mulai');
  await Future.delayed(const Duration(seconds: 5));
  print('5. Async: selesai setelah 5 detik');
}

Future<void> main() async {
  sinkron();
  print('--- baris ini baru tercetak SETELAH sinkron selesai');

  final f = asinkron();
  print('4. Baris ini tercetak LANGSUNG, tanpa menunggu async');
  await f;
}