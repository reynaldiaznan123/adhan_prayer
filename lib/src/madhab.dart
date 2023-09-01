enum Madhab {
  // Shafi, Maliki, Hanbali
  standard,
  
  // Hanafi
  hanafi,
}

extension MadhabExtensions on Madhab {
  double getShadowLength() {
    switch (this) {
      case Madhab.standard:
        return 1.0;
      case Madhab.hanafi:
        return 2.0;
      default:
        throw const FormatException('Invalid Madhab');
    }
  }
}
