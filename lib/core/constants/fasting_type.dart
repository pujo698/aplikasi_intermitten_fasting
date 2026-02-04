enum FastingType {
  fasting16_8,
  fasting18_6,
  fasting20_4,
  custom,
}

int getEatingHours(FastingType type) {
  switch (type) {
    case FastingType.fasting16_8:
      return 8;
    case FastingType.fasting18_6:
      return 6;
    case FastingType.fasting20_4:
      return 4;
    case FastingType.custom:
      return 0;
  }
}
