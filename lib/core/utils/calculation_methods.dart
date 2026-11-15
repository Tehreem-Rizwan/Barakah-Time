/// Prayer-time calculation methods supported by the app.
///
/// [id] is what is persisted in settings / Firestore and passed to
/// `AdhanService`; [l10nKey] is the localization key for the display name.
class CalculationMethodInfo {
  final String id;
  final String l10nKey;
  final String englishName;
  const CalculationMethodInfo(this.id, this.l10nKey, this.englishName);
}

class CalculationMethods {
  CalculationMethods._();

  static const String karachi = 'Karachi';
  static const String isna = 'ISNA';
  static const String mwl = 'MWL';
  static const String ummAlQura = 'Makkah';
  static const String dubai = 'Dubai';
  static const String qatar = 'Qatar';
  static const String kuwait = 'Kuwait';
  static const String egyptian = 'Egyptian';
  static const String turkey = 'Turkey';
  static const String tehran = 'Tehran';
  static const String singapore = 'Singapore';
  static const String moonsighting = 'MoonsightingCommittee';

  /// Display order for the settings picker.
  static const List<CalculationMethodInfo> all = [
    CalculationMethodInfo(mwl, 'method_mwl', 'Muslim World League'),
    CalculationMethodInfo(
      karachi,
      'method_karachi',
      'University of Islamic Sciences, Karachi',
    ),
    CalculationMethodInfo(
      isna,
      'method_isna',
      'Islamic Society of North America (ISNA)',
    ),
    CalculationMethodInfo(
      ummAlQura,
      'method_umm_al_qura',
      'Umm al-Qura University, Makkah',
    ),
    CalculationMethodInfo(
      egyptian,
      'method_egyptian',
      'Egyptian General Authority of Survey',
    ),
    CalculationMethodInfo(dubai, 'method_dubai', 'Dubai (UAE)'),
    CalculationMethodInfo(qatar, 'method_qatar', 'Qatar'),
    CalculationMethodInfo(kuwait, 'method_kuwait', 'Kuwait'),
    CalculationMethodInfo(
      turkey,
      'method_turkey',
      'Diyanet İşleri Başkanlığı, Turkey',
    ),
    CalculationMethodInfo(
      tehran,
      'method_tehran',
      'Institute of Geophysics, University of Tehran',
    ),
    CalculationMethodInfo(
      singapore,
      'method_singapore',
      'Majlis Ugama Islam Singapura (Singapore, Malaysia, Indonesia)',
    ),
    CalculationMethodInfo(
      moonsighting,
      'method_moonsighting',
      'Moonsighting Committee Worldwide',
    ),
  ];

  static List<String> get ids => [for (final m in all) m.id];

  static bool isKnown(String? id) => id != null && ids.contains(id);

  static CalculationMethodInfo? byId(String id) {
    for (final m in all) {
      if (m.id == id) return m;
    }
    return null;
  }

  static const Set<String> _europe = {
    'GB',
    'IE',
    'FR',
    'DE',
    'NL',
    'BE',
    'LU',
    'AT',
    'CH',
    'IT',
    'ES',
    'PT',
    'DK',
    'SE',
    'NO',
    'FI',
    'IS',
    'PL',
    'CZ',
    'SK',
    'HU',
    'SI',
    'HR',
    'BA',
    'RS',
    'ME',
    'MK',
    'AL',
    'XK',
    'GR',
    'BG',
    'RO',
    'MD',
    'UA',
    'LT',
    'LV',
    'EE',
    'MT',
    'CY',
  };

  /// Sensible default for a device region (ISO 3166 alpha-2), used only when
  /// the user has not chosen a method yet.
  static String defaultForCountry(String? countryCode) {
    final cc = countryCode?.trim().toUpperCase();
    if (cc == null || cc.isEmpty) return mwl;
    switch (cc) {
      case 'PK':
      case 'IN':
      case 'BD':
      case 'AF':
        return karachi;
      case 'US':
      case 'CA':
        return isna;
      case 'SA':
      case 'YE':
        return ummAlQura;
      case 'AE':
        return dubai;
      case 'QA':
        return qatar;
      case 'KW':
        return kuwait;
      case 'TR':
        return turkey;
      case 'EG':
      case 'SD':
      case 'LY':
        return egyptian;
      case 'IR':
        return tehran;
      case 'SG':
      case 'MY':
      case 'ID':
      case 'BN':
        return singapore;
    }
    if (_europe.contains(cc)) return moonsighting;
    return mwl;
  }
}
