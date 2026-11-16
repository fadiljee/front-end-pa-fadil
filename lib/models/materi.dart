/// Detail konten sebuah materi pembelajaran.
class MateriDetail {
  const MateriDetail({required this.konten, this.gambarUrl});

  final String konten;
  final String? gambarUrl;
}

/// Hasil permintaan pembukaan materi berikutnya (`POST /unlock-next-materi`).
class UnlockMateriResult {
  const UnlockMateriResult({required this.unlocked, required this.message});

  final bool unlocked;
  final String message;
}
