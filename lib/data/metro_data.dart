import 'package:flutter/material.dart';

/// A single Cairo Metro line (or branch) with its ordered station list.
class MetroLine {
  const MetroLine({
    required this.id,
    required this.name,
    required this.color,
    required this.stations,
  });

  final String id;
  final String name;
  final Color color;
  final List<String> stations;

  String get shortName => id;
}

/// Stations shared by Line 3 and Line 4 between Adly Mansour and Kit-Kat.
const List<String> commonStations = [
  'Adly Mansour',
  'Haykestep',
  'Omar Ibn El Khattab',
  'Qubaa',
  'Hesham Barakat',
  'El Nozha',
  'El Shams Club',
  'Alf Maskan',
  'Heliopolis',
  'Haroun',
  'Al-Ahram',
  'Koleyet El-Banat',
  'Stadium',
  'Fair Zone',
  'Abbassiya',
  'Abdou Pasha',
  'El-Geish',
  'Bab El Shaariya',
  'Attaba',
  'Nasser',
  'Maspero',
  'Safaa Hijazy',
  'Kit-Kat',
];

const List<MetroLine> metroLines = [
  MetroLine(
    id: 'L1',
    name: 'Line 1',
    color: Color(0xFF1565C0),
    stations: [
      'Helwan',
      'Ain Helwan',
      'Helwan University',
      'Wadi Hof',
      'Hadayek Helwan',
      'El-Masraa',
      'Tura El-Esmant',
      'Kozzika',
      'Tora El-Balad',
      'Sakanat El-Maadi',
      'Maadi',
      'Hadayek El-Maadi',
      'Dar El-Salam',
      'El-Zahraa',
      'Mar Girgis',
      'El-Malek El-Saleh',
      'Al-Sayeda Zeinab',
      'Saad Zaghloul',
      'Sadat',
      'Nasser',
      'Orabi',
      'Al-Shohadaa',
      'Ghamra',
      'El-Demerdash',
      'Manshiet El-Sadr',
      'Kobri El-Qobba',
      'Hammamat El-Qobba',
      'Saray El-Qobba',
      'Hadayeq El-Zaitoun',
      'Helmeyet El-Zaitoun',
      'El-Matareyya',
      'Ain Shams',
      'Ezbet El-Nakhl',
      'El-Marg',
      'New Marg',
    ],
  ),
  MetroLine(
    id: 'L2',
    name: 'Line 2',
    color: Color(0xFFC62828),
    stations: [
      'El Monib',
      'Sakiat Mekky',
      'Omm El-Masryeen',
      'Giza',
      'Faisal',
      'Cairo University',
      'El Bohoth',
      'Dokki',
      'Opera',
      'Sadat',
      'Mohamed Naguib',
      'Attaba',
      'Al-Shohadaa',
      'Masarra',
      'Rod El-Farag',
      'St. Teresa',
      'Khalafawy',
      'Mezallat',
      'Koliet El-Zeraa',
      'Shubra Al Khaimah',
    ],
  ),
  MetroLine(
    id: 'L3',
    name: 'Line 3',
    color: Color(0xFF2E7D32),
    stations: [
      ...commonStations,
      'Sudan',
      'Imbaba',
      'El-Bohy',
      'El-Qawmia',
      'Ring Road',
      'Rod El Farag Corridor',
    ],
  ),
  MetroLine(
    id: 'L4',
    name: 'Line 4',
    color: Color(0xFF6A1B9A),
    stations: [
      ...commonStations,
      'Tawfikia',
      'Wadi El Nile',
      'Gamet El Dowel',
      'Boulak El Dakrour',
      'Cairo University',
    ],
  ),
];

/// A well-known area or landmark mapped to the closest metro station.
class MetroArea {
  const MetroArea({
    required this.name,
    required this.station,
    this.aliases = const [],
  });

  final String name;
  final String station;
  final List<String> aliases;

  Iterable<String> get searchTerms => [name, ...aliases];
}

const List<MetroArea> metroAreas = [
  MetroArea(
    name: 'Nasr City',
    station: 'Stadium',
    aliases: ['nasr city', 'nasrcity', 'city stars', 'citystars', 'مدينة نصر', 'نصر سيتي'],
  ),
  MetroArea(
    name: 'Downtown / Tahrir',
    station: 'Sadat',
    aliases: ['downtown', 'tahrir', 'tahrir square', 'el tahrir', 'وسط البلد', 'التحرير'],
  ),
  MetroArea(
    name: 'Zamalek',
    station: 'Opera',
    aliases: ['zamalek', 'الزمالك'],
  ),
  MetroArea(
    name: 'Mohandessin',
    station: 'Dokki',
    aliases: ['mohandessin', 'mohandiseen', 'mohandeseen', 'المهندسين'],
  ),
  MetroArea(
    name: 'Haram',
    station: 'Faisal',
    aliases: ['haram', 'haram street', 'الهرم', 'فيصل'],
  ),
  MetroArea(
    name: 'New Cairo',
    station: 'Adly Mansour',
    aliases: ['new cairo', 'tagamoa', 'fifth settlement', 'القاهرة الجديدة', 'التجمع'],
  ),
  MetroArea(
    name: '6th of October',
    station: 'Cairo University',
    aliases: ['6th october', 'sixth october', '6 october', 'اكتوبر', 'السادس من اكتوبر'],
  ),
  MetroArea(
    name: 'Sheikh Zayed',
    station: 'Cairo University',
    aliases: ['sheikh zayed', 'الشيخ زايد'],
  ),
  MetroArea(
    name: 'Garden City',
    station: 'Saad Zaghloul',
    aliases: ['garden city', 'جاردن سيتي'],
  ),
  MetroArea(
    name: 'Old Cairo',
    station: 'Mar Girgis',
    aliases: ['old cairo', 'coptic cairo', 'مصر القديمة', 'مجمع الاديان'],
  ),
  MetroArea(
    name: 'Manial',
    station: 'El-Malek El-Saleh',
    aliases: ['manial', 'el manial', 'المنيل'],
  ),
  MetroArea(
    name: 'Mokattam',
    station: 'Abbassiya',
    aliases: ['mokattam', 'المقطم'],
  ),
  MetroArea(
    name: 'Khan el-Khalili',
    station: 'Bab El Shaariya',
    aliases: ['khan el khalili', 'khan elkhalili', 'hussein', 'al azhar', 'azhar', 'خان الخليلي', 'الحسين', 'الازهر'],
  ),
  MetroArea(
    name: 'Ramses',
    station: 'Al-Shohadaa',
    aliases: ['ramses', 'ramsis', 'cairo station', 'محطة مصر', 'رمسيس'],
  ),
  MetroArea(
    name: 'Ataba',
    station: 'Attaba',
    aliases: ['ataba', 'العتبة'],
  ),
  MetroArea(
    name: 'Shubra',
    station: 'Shubra Al Khaimah',
    aliases: ['shubra', 'shobra', 'شبرا', 'شبرا الخيمة'],
  ),
  MetroArea(
    name: 'Heliopolis',
    station: 'Haroun',
    aliases: ['heliopolis', 'masr el gedida', 'مصر الجديدة', 'هليوبوليس'],
  ),
  MetroArea(
    name: 'Abbassiya',
    station: 'Abbassiya',
    aliases: ['abbassiya', 'abbasiya', 'abbassia', 'العباسية'],
  ),
  MetroArea(
    name: 'Giza Square',
    station: 'Giza',
    aliases: ['giza square', 'giza', 'الجيزة', 'ميدان الجيزة'],
  ),
  MetroArea(
    name: 'Maadi',
    station: 'Maadi',
    aliases: ['maadi', 'المعادي'],
  ),
  MetroArea(
    name: 'Ghamra',
    station: 'Ghamra',
    aliases: ['ghamra', 'غمرة'],
  ),
  MetroArea(
    name: 'Helwan',
    station: 'Helwan',
    aliases: ['helwan', 'حلوان'],
  ),
  MetroArea(
    name: 'Shorouk',
    station: 'Adly Mansour',
    aliases: ['shorouk', 'shorouk city', 'الشروق'],
  ),
  MetroArea(
    name: 'Obour',
    station: 'Adly Mansour',
    aliases: ['obour', 'obour city', 'العبور'],
  ),
  MetroArea(
    name: 'Badr City',
    station: 'Adly Mansour',
    aliases: ['badr', 'badr city', 'بدر'],
  ),
  MetroArea(
    name: 'Madinaty',
    station: 'Adly Mansour',
    aliases: ['madinaty', 'مدينتي'],
  ),
  MetroArea(
    name: 'Al Rehab',
    station: 'Adly Mansour',
    aliases: ['rehab', 'al rehab', 'الرحاب'],
  ),
  MetroArea(
    name: 'Sayeda Zeinab',
    station: 'Al-Sayeda Zeinab',
    aliases: ['sayeda zeinab', 'el sayeda zeinab', 'السيدة زينب'],
  ),
  MetroArea(
    name: 'Cairo University',
    station: 'Cairo University',
    aliases: ['cairo university', 'جامعة القاهرة'],
  ),
  MetroArea(
    name: 'Kit-Kat',
    station: 'Kit-Kat',
    aliases: ['kit kat', 'kitkat', 'الكيت كات'],
  ),
];

/// Every station in the network, sorted alphabetically.
final List<String> allStations = () {
  final names = <String>{};
  for (final line in metroLines) {
    names.addAll(line.stations);
  }
  final sorted = names.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return List<String>.unmodifiable(sorted);
}();

/// Fare tiers, based on the number of stops travelled.
const List<FareTier> fareTiers = [
  FareTier(minStops: 1, maxStops: 9, price: 9),
  FareTier(minStops: 10, maxStops: 16, price: 12),
  FareTier(minStops: 17, maxStops: 23, price: 15),
  FareTier(minStops: 24, maxStops: null, price: 20),
];

class FareTier {
  const FareTier({
    required this.minStops,
    required this.maxStops,
    required this.price,
  });

  final int minStops;
  final int? maxStops;
  final int price;

  String get label =>
      maxStops == null ? '$minStops+ stops' : '$minStops–$maxStops stops';
}
