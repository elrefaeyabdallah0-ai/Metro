// ignore_for_file: avoid_print
import 'dart:io';

final common = [
  'Adly Mansour', 'Haykestep', 'Omar Ibn El Khattab', 'Qubaa', 'Hesham Barakat',
  'El Nozha', 'El Shams Club', 'Alf Maskan', 'Heliopolis', 'Haroun', 'Al-Ahram',
  'Koleyet El-Banat', 'Stadium', 'Fair Zone', 'Abbassiya', 'Abdou Pasha',
  'El-Geish', 'Bab El Shaariya', 'Attaba', 'Nasser', 'Maspero', 'Safaa Hijazy', 'Kit-Kat',
];

final lines = [
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

List<String> part(List<String> line, String a, String b) {
  int i = line.indexOf(a);
  int j = line.indexOf(b);
  if (i < j) return line.sublist(i, j + 1);
  return line.sublist(j, i + 1).reversed.toList();
}

String direction(List<String> line, String a, String b) {
  return line.indexOf(a) < line.indexOf(b) ? line.last : line.first;
}

String readStation(String message) {
  while (true) {
    stdout.write(message);
    String input = (stdin.readLineSync() ?? '').trim().toLowerCase();
    for (var line in lines) {
      for (var s in line) {
        if (s.toLowerCase() == input) return s;
      }
    }
    print('المحطة غير موجودة، حاول مرة أخرى.');
  }
}

void main() {
  String from = readStation('محطة الركوب: ');
  String to = readStation('محطة الوصول: ');

  if (from == to) {
    print('محطة الركوب هي نفسها محطة الوصول');
    return;
  }

  List<String> bestRoute = [];
  String bestDirections = '';

  for (var a in lines) {
    if (!a.contains(from)) continue;
    for (var b in lines) {
      if (!b.contains(to)) continue;

      if (a == b) {
        var route = part(a, from, to);
        if (bestRoute.isEmpty || route.length < bestRoute.length) {
          bestRoute = route;
          bestDirections = 'اركب من $from باتجاه ${direction(a, from, to)}';
        }
      } else {
        for (var t in a) {
          if (!b.contains(t) || t == from || t == to) continue;
          var route = [...part(a, from, t), ...part(b, t, to).sublist(1)];
          if (bestRoute.isEmpty || route.length < bestRoute.length) {
            bestRoute = route;
            bestDirections = 'اركب من $from باتجاه ${direction(a, from, t)}، '
                'ثم غير في محطة $t واركب باتجاه ${direction(b, t, to)}';
          }
        }
      }
    }
  }

  int count = bestRoute.length - 1;
  int price;
  if (count <= 9) {
    price = 9;
  } else if (count <= 16) {
    price = 12;
  } else if (count <= 23) {
    price = 15;
  } else {
    price = 20;
  }

  print('\nعدد المحطات: $count');
  print('الوقت التقديري: ${count * 2} دقيقة');
  print('سعر التذكرة: $price جنيه');
  print('الاتجاه: $bestDirections');
  print('\nخط السير:');
  for (var i = 0; i < bestRoute.length; i++) {
    print('${i + 1}. ${bestRoute[i]}');
  }
}
