/// Extension on num for responsive spacing or layout.
extension NumExtensions on num {
  /// Returns this value as a responsive factor (e.g. 1.5 for tablets).
  double responsive(double mobile, [double? tablet, double? desktop]) {
    // Default: same as mobile if tablet/desktop not provided.
    return toDouble();
  }
}
