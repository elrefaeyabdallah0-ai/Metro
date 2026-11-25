// ignore_for_file: avoid_print
import 'dart:io';

var common = [
  'Adly Mansour', 'Haykestep', 'Omar Ibn El Khattab', 'Qubaa', 'Hesham Barakat',
  'El Nozha', 'El Shams Club', 'Alf Maskan', 'Heliopolis', 'Haroun', 'Al-Ahram',
  'Koleyet El-Banat', 'Stadium', 'Fair Zone', 'Abbassiya', 'Abdou Pasha',
  'El-Geish', 'Bab El Shaariya', 'Attaba', 'Nasser', 'Maspero', 'Safaa Hijazy', 'Kit-Kat',
];

var lines = [
  [
    'Helwan', 'Ain Helwan', 'Helwan University', 'Wadi Hof', 'Hadayek Helwan',
    'El-Masraa', 'Tura El-Esmant', 'Kozzika', 'Tora El-Balad', 'Sakanat El-Maadi',
    'Maadi', 'Hadayek El-Maadi', 'Dar El-Salam', 'El-Zahraa', 'Mar Girgis',
    'El-Malek El-Saleh', 'Al-Sayeda Zeinab', 'Saad Zaghloul', 'Sadat', 'Nasser',
    'Orabi', 'Al-Shohadaa', 'Ghamra', 'El-Demerdash', 'Manshiet El-Sadr',
    'Kobri El-Qobba', 'Hammamat El-Qobba', 'Saray El-Qobba', 'Hadayeq El-Zaitoun',
    'Helmeyet El-Zaitoun', 'El-Matareyya', 'Ain Shams', 'Ezbet El-Nakhl', 'El-Marg', 'New Marg',
  ],
  [
    'El Monib', 'Sakiat Mekky', 'Omm El-Masryeen', 'Giza', 'Faisal', 'Cairo University',
    'El Bohoth', 'Dokki', 'Opera', 'Sadat', 'Mohamed Naguib', 'Attaba', 'Al-Shohadaa',
    'Masarra', 'Rod El-Farag', 'St. Teresa', 'Khalafawy', 'Mezallat', 'Koliet El-Zeraa',
    'Shubra Al Khaimah',
  ],
  [...common, 'Sudan', 'Imbaba', 'El-Bohy', 'El-Qawmia', 'Ring Road', 'Rod El Farag Corridor'],
  [...common, 'Tawfikia', 'Wadi El Nile', 'Gamet El Dowel', 'Boulak El Dakrour', 'Cairo University'],
];

var transfers = ['Sadat', 'Al-Shohadaa', 'Attaba', 'Nasser', 'Cairo University', 'Kit-Kat'];

List<String>? sameLine(String a, String b) {
  for (var l in lines) {
    if (l.contains(a) && l.contains(b)) return l;
  }
  return null;
}

List<String> part(List<String> l, String a, String b) {
  int i = l.indexOf(a), j = l.indexOf(b);
  return i < j ? l.sublist(i, j + 1) : l.sublist(j, i + 1).reversed.toList();
}

String go(List<String> l, String a, String b) =>
    'من $a باتجاه ${l.indexOf(a) < l.indexOf(b) ? l.last : l.first}';

void main() {
  stdout.write('محطة الركوب: ');
  String from = stdin.readLineSync()!.trim();
  stdout.write('محطة الوصول: ');
  String to = stdin.readLineSync()!.trim();

  List<String> route = [];
  String directions = '';

  var line = sameLine(from, to);
  if (line != null) {
    route = part(line, from, to);
    directions = go(line, from, to);
  } else {
    for (var t in transfers) {
      var l1 = sameLine(from, t);
      var l2 = sameLine(t, to);
      if (l1 == null || l2 == null) continue;
      var r = [...part(l1, from, t), ...part(l2, t, to).sublist(1)];
      if (route.isEmpty || r.length < route.length) {
        route = r;
        directions = '${go(l1, from, t)} ثم غيّر في $t ${go(l2, t, to)}';
      }
    }
  }

  int count = route.length - 1;
  int price = 20;
  if (count <= 9) {
    price = 9;
  } else if (count <= 16) {
    price = 12;
  } else if (count <= 23) {
    price = 15;
  }

  print('\nعدد المحطات: $count');
  print('الوقت التقديري: ${count * 2} دقيقة');
  print('سعر التذكرة: $price جنيه');
  print('الاتجاه: $directions');
  print('\nخط السير:');
  for (var s in route) {
    print('- $s');
  }
}
