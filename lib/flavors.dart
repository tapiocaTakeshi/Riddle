enum Flavor {
  DEV,
  PROD,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.DEV:
        return 'dev riddle';
      case Flavor.PROD:
        return 'prod riddle';
      default:
        return 'title';
    }
  }

}
