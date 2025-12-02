class ProgressHelper {
  static double progress(int? pos, int? dur) {
    if (pos == null || dur == null || dur == 0) return 0;
    return (pos / dur).clamp(0.0, 1.0);
  }

  static bool isCompleted(int? pos, int? dur) {
    if (pos == null || dur == 0) return false;
    return (pos / dur!) > 0.9;
  }
}
