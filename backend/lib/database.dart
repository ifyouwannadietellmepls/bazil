import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class Database {
  static final Map<String, Map<String, dynamic>> _users = {};
  static final List<Map<String, dynamic>> _transactions = [];
  static final List<Map<String, dynamic>> _menuItems = [];
  static final List<Map<String, dynamic>> _events = [];
  static const _uuid = Uuid();
  static String? _dbPath;

  static Response _jsonResponse(int statusCode, Map<String, dynamic> data) {
    return Response(statusCode, body: jsonEncode(data), headers: {'content-type': 'application/json; charset=utf-8'});
  }

  static Response _jsonListResponse(int statusCode, List<dynamic> data) {
    return Response(statusCode, body: jsonEncode(data), headers: {'content-type': 'application/json; charset=utf-8'});
  }

  static String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }

  static String _generateSalt() {
    final random = Random.secure();
    return base64.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  static String _generateTempPassword() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
    final random = Random.secure();
    return List.generate(12, (index) => chars[random.nextInt(chars.length)]).join();
  }

  static Future<void> _saveToFile() async {
    if (_dbPath == null) return;
    final file = File(_dbPath!);
    await file.create(recursive: true);
    final data = {
      'users': _users.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v))),
      'transactions': _transactions.map((t) => Map<String, dynamic>.from(t)).toList(),
      'menuItems': _menuItems.map((m) => Map<String, dynamic>.from(m)).toList(),
      'events': _events.map((e) => Map<String, dynamic>.from(e)).toList(),
    };
    await file.writeAsString(jsonEncode(data));
  }

  static Future<void> _loadFromFile() async {
    if (_dbPath == null) return;
    final file = File(_dbPath!);
    if (!await file.exists()) return;
    try {
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      _users.clear();
      _transactions.clear();
      _menuItems.clear();
      _events.clear();
      
      (data['users'] as Map<String, dynamic>?)?.forEach((k, v) => _users[k] = Map<String, dynamic>.from(v as Map));
      (data['transactions'] as List?)?.forEach((e) => _transactions.add(Map<String, dynamic>.from(e as Map)));
      (data['menuItems'] as List?)?.forEach((e) => _menuItems.add(Map<String, dynamic>.from(e as Map)));
      (data['events'] as List?)?.forEach((e) => _events.add(Map<String, dynamic>.from(e as Map)));
    } catch (e) {
      print('❌ Error loading DB: $e');
    }
  }

  static Future<void> init() async {
    _dbPath = path.join(Directory.current.path, 'data', 'db.json');
    await _loadFromFile();
    
    if (_users.isEmpty) {
      final tempPassword = _generateTempPassword();
      final adminSalt = _generateSalt();
      
      _users['admin01'] = {
        'userId': 'admin01',
        'phone': '+79990000000',
        'firstName': 'Админ',
        'lastName': 'Кафе',
        'passwordHash': _hashPassword(tempPassword, adminSalt),
        'salt': adminSalt,
        'role': 'admin',
        'totalSpent': 0.0,
        'status': 'Start',
        'discount': 0,
        'createdAt': DateTime.now().toIso8601String(),
        'mustChangePassword': true,
      };
      await _saveToFile();
      print('\n🔐 ВРЕМЕННЫЙ ПАРОЛЬ АДМИНА: $tempPassword\n');
    }
    
    if (_menuItems.isEmpty) {
      _initializeMenuFromPDF();
      await _saveToFile();
    }
    
    // ← ДОБАВЛЕНО: инициализация тестовых событий
    if (_events.isEmpty) {
      _initializeEvents();
      await _saveToFile();
    }
  }

  static void _initializeMenuFromPDF() {
    final menuData = [
      {'category': '🥗 Холодные закуски и Салаты', 'items': [
        {'name': 'Сырное плато', 'description': 'горгонзола/бри/пармезан/чеддер', 'price': '370/1250 ₽'},
        {'name': 'Мясное ассорти', 'description': 'бастурма/салями/куриный рулет/ростбиф', 'price': '320/1350 ₽'},
        {'name': 'Овощное ассорти', 'description': 'огурцы/томаты/сельдерей/морковь/перец/соус тар-тар', 'price': '420/850 ₽'},
        {'name': 'Брускетта с лососем', 'description': 'лосось/авокадо/крем-сыр/огурец/томаты', 'price': '210/800 ₽'},
        {'name': 'Брускетта с крабом', 'description': 'краб/томат/зеленый салат/крем-сыр', 'price': '200/750 ₽'},
        {'name': 'Тар-Тар из лосося', 'description': 'лосось/авокадо/огурец/каперсы/лук/перец', 'price': '220/800 ₽'},
        {'name': 'Тар-тар из тунца', 'description': 'тунец/авокадо/огурец/каперсы/лук/перец', 'price': '220/780 ₽'},
        {'name': 'Тар-тар из говядины', 'description': 'говядина/лук/соленый огурец/желток/каперсы', 'price': '230/800 ₽'},
        {'name': 'Цезарь с курицей', 'description': 'листья салата/курица/черри/сухарики/соус цезарь', 'price': '230/750 ₽'},
        {'name': 'Цезарь с креветками', 'description': 'листья салата/креветки/черри/сухарики/соус цезарь', 'price': '230/790 ₽'},
        {'name': 'Греческий салат', 'description': 'огурцы/томаты/оливки/фетакса/перец/лук', 'price': '240/650 ₽'},
        {'name': 'Нисуаз с тунцом', 'description': 'салат айсберг/маслины/картофель/тунец/яйцо/черри', 'price': '240/800 ₽'},
        {'name': 'Салат с хрустящими баклажанами', 'description': 'баклажаны фри/томаты/кинза/заправка', 'price': '245/680 ₽'},
        {'name': 'Теплый морской салат', 'description': 'ассорти из морепродуктов/томаты/салатные листья/заправка', 'price': '250/890 ₽'},
        {'name': 'Авокадо с креветками', 'description': 'авокадо/томаты/креветки/листья салата/соус песто', 'price': '200/850 ₽'},
        {'name': 'Теплый салат с куриной печенью', 'description': 'руккола/романо/айсберг/куриная печень/грейпфрут', 'price': '245/750 ₽'},
      ]},
      {'category': '🔥 Горячие закуски', 'items': [
        {'name': 'Жареный сулугуни', 'description': 'сулугуни/кунжут/ягодный соус', 'price': '265/700 ₽'},
        {'name': 'Домашние чесночные гренки', 'description': 'гренки/чесночное масло/соус тар-тар', 'price': '200/450 ₽'},
        {'name': 'Креветки Васаби', 'description': 'креветки Ваннамей/соус васаби', 'price': '190/650 ₽'},
        {'name': 'Креветки на гриле', 'description': 'креветки Ваннамей/лайм/кисло-сладкий соус', 'price': '200/790 ₽'},
        {'name': 'Картофель фри / Батат фри', 'description': 'с пармезаном', 'price': '150/350 ₽'},
        {'name': 'Картофель по-деревенски', 'description': 'запеченный со специями', 'price': '150/350 ₽'},
        {'name': 'Луковые кольца', 'description': '6 шт', 'price': '300 ₽'},
        {'name': 'Кольца кальмара', 'description': '6 шт', 'price': '380 ₽'},
        {'name': 'Сырные палочки', 'description': 'из моцареллы, 6 шт', 'price': '400 ₽'},
        {'name': 'Куриные крылышки / BBQ', 'description': '5 шт', 'price': '450 ₽'},
        {'name': 'Наггетсы / Стрипсы', 'description': '6 шт / 5 шт', 'price': '400 ₽'},
        {'name': 'Сет №1', 'description': 'крылышки/фри/луковые кольца', 'price': '320/950 ₽'},
        {'name': 'Сет №2', 'description': 'сырные палочки/кольца/стрипсы/фри', 'price': '380/1250 ₽'},
        {'name': 'Сет №3', 'description': 'креветки/кольца кальмара/картофель', 'price': '325/1150 ₽'},
        {'name': 'Сет №4', 'description': 'наггетсы/сырные палочки/картофель', 'price': '320/990 ₽'},
        {'name': 'Сет на компанию', 'description': 'крылышки/картофель 2 вида/кольца/сырные палочки/кальмары', 'price': '560/1650 ₽'},
      ]},
      {'category': '🍔 Бургеры и Роллы', 'items': [
        {'name': 'Блю Чиз бургер', 'description': 'котлета из мраморной говядины/соус блю чиз/салат/лук/томаты', 'price': '410/750 ₽'},
        {'name': 'Итальянский бургер', 'description': 'говядина/перец на гриле/лук/томаты/пармезан/салат', 'price': '410/750 ₽'},
        {'name': 'Бургер со стрипсами', 'description': 'куриные стрипсы/огурчик/соус/сыр/салат/томаты', 'price': '390/650 ₽'},
        {'name': 'Ролл с говядиной', 'description': 'лепешка/вырезка/томаты/лук/салат/сыр', 'price': '380/690 ₽'},
        {'name': 'Ролл с курицей', 'description': 'лепешка/грудка/томаты/лук/салат/сыр', 'price': '380/650 ₽'},
        {'name': 'Клаб-сэндвич', 'description': 'Тосты/куриная грудка/томаты/лук/салат/сыр', 'price': '390/700 ₽'},
      ]},
      {'category': '🍕 Пицца 30 см', 'items': [
        {'name': 'Маргарита', 'description': 'домашнее тесто/соус песто/сыр', 'price': '750 ₽'},
        {'name': 'Четыре сыра', 'description': 'пармезан/моцарелла/горгонзола/чеддер', 'price': '850 ₽'},
        {'name': 'Пепперони', 'description': 'соус/пепперони/сыр', 'price': '850 ₽'},
        {'name': 'Барбекью', 'description': 'сыр/соус/красный лук/бекон/грибы', 'price': '850 ₽'},
        {'name': 'Пицца с цыпленком', 'description': 'сыр/соус/мясо цыпленка/томаты', 'price': '850 ₽'},
        {'name': 'Пицца «Цезарь»', 'description': 'соус цезарь/пармезан/куриная грудка/листья салата', 'price': '850 ₽'},
        {'name': 'Пицца с морепродуктами', 'description': 'соус/кальмары/креветки/пармезан', 'price': '950 ₽'},
      ]},
      {'category': '🍝 Паста', 'items': [
        {'name': 'Карбонара', 'description': 'спагетти/бекон/пармезан/сливки', 'price': '290/700 ₽'},
        {'name': 'Пенне с курицей и грибами', 'description': 'пенне/курица/шампиньоны/пармезан/сливочный соус', 'price': '290/700 ₽'},
        {'name': 'Паста с креветками', 'description': 'паста/томатно-сливочный соус/креветки/пармезан', 'price': '280/750 ₽'},
        {'name': 'Паста с томатным соусом', 'description': 'пенне/томатный соус/базилик', 'price': '270/650 ₽'},
        {'name': 'Паста с морепродуктами', 'description': 'спагетти/томатный соус/креветки/мидии', 'price': '270/850 ₽'},
      ]},
      {'category': '🥘 Супы и Выпечка', 'items': [
        {'name': 'Том Ям', 'description': 'подается с рисом', 'price': '400/850 ₽'},
        {'name': 'Куриный суп с лапшой', 'description': 'бульон/лапша/яйцо', 'price': '400/850 ₽'},
        {'name': 'Борщ с говядиной', 'description': 'подается со сметаной и гренками', 'price': '390/750 ₽'},
        {'name': 'Харчо', 'description': 'с говядиной', 'price': '350/450 ₽'},
        {'name': 'Хачапури по-аджарски', 'description': 'домашнее тесто/сыр/яйцо', 'price': '360/600 ₽'},
        {'name': 'Хачапури по-мегрельски', 'description': 'домашнее тесто/сыр', 'price': '350/600 ₽'},
      ]},
      {'category': '🦪 Мидии', 'items': [
        {'name': 'Мидии в соусе блю чиз', 'description': 'мидии в створках/соус блю чиз', 'price': '490/700 ₽'},
        {'name': 'Мидии в томатном соусе', 'description': 'мидии в створках/томатный соус', 'price': '580/750 ₽'},
      ]},
      {'category': '🥩 Горячие блюда', 'items': [
        {'name': 'Чипсы', 'description': 'сырные/с солью/лук/сметана и зелень', 'price': '290/890 ₽'},
        {'name': 'Сыр Чечил копченый', 'description': '', 'price': '290/950 ₽'},
        {'name': 'Арахис / Фисташки', 'description': '', 'price': '320/800 ₽'},
        {'name': 'Манты', 'description': 'традиционные, с соусом тар-тар и аджикой', 'price': '290/790 ₽'},
        {'name': 'Люля из курицы', 'description': 'куриный люля/картофель', 'price': '200/1100 ₽'},
        {'name': 'Люля из говядины', 'description': 'люля из говядины/овощной салат', 'price': '290/950 ₽'},
        {'name': 'Корейка баранины на гриле', 'description': 'корейка, лаваш, маринованный лук', 'price': '320/750 ₽'},
        {'name': 'Стейк тунца', 'description': 'тунец/картофель/соус', 'price': '310/500 ₽'},
        {'name': 'Бефстроганов', 'description': 'картофельное пюре/говядина/лук/соус', 'price': '310/750 ₽'},
        {'name': 'Шашлык из курицы', 'description': 'подается с салатом и соусом', 'price': '310/650 ₽'},
        {'name': 'Стейк Форели / Филе миньон', 'description': 'на гриле', 'price': '330/600 ₽'},
        {'name': 'Сковорода СССР', 'description': 'говядина/шампиньоны/помидоры/лук/сыр чеддер', 'price': '325/650 ₽'},
        {'name': 'Овощи гриль', 'description': 'баклажаны/кабачки/шампиньоны', 'price': '320/790 ₽'},
        {'name': 'Говядина в азиатском стиле', 'description': 'говядина/перец/морковь/огурцы/лук/азиатский соус/рис', 'price': '290/890 ₽'},
        {'name': 'Говядина с картошкой и грибами', 'description': 'говядина/лук/картофель/шампиньоны/специи', 'price': '290/950 ₽'},
        {'name': 'Удон с курицей или говядиной', 'description': '', 'price': '320/800 ₽'},
      ]},
      {'category': '🍹 Напитки и Чай', 'items': [
        {'name': 'Домашний лимонад', 'description': 'Манго-маракуйя / Цитрусовый / Маракуйя-малина / Грейпфрут-малина / Ягодный / Лаванда-малина / Мохито', 'price': '450/950 ₽'},
        {'name': 'Газировка / Вода / Сок / Фреш', 'description': 'Кока-кола / Вода / Сок / Апельсиновый / Грейпфрутовый', 'price': '250-450 ₽'},
        {'name': 'Кофе', 'description': 'Американо / Капучино / Латте / Эспрессо', 'price': '200-250 ₽'},
        {'name': 'Чай классический', 'description': 'Ассам / Эрл грей / Сенча / Молочный улун / Зеленый с жасмином', 'price': '500/600 ₽ (500/1000 мл)'},
        {'name': 'Нечайный чай (фруктово-ягодный)', 'description': 'Клюква-имбирь / Лимон-имбирь / Облепиховый / Манго-маракуйя / Ягодный', 'price': '770 ₽ (1000 мл)'},
        {'name': 'Добавки к чаю', 'description': 'лимон/мята/чабрец/мёд', 'price': '100 ₽'},
      ]},
      {'category': '☕ Паровые коктейли и Кальяны', 'items': [
        {'name': 'Кальян премиум + чай', 'description': 'Классическая чаша / Грейпфрут / Гранат / Ананас / Сигарный табак', 'price': '1900-2800 ₽'},
        {'name': 'Кальянный ланч', 'description': 'Кальян премиум + чай зеленый/черный', 'price': '1800 ₽'},
        {'name': 'Паровые коктейли', 'description': 'Облепиховый / Цитрусовый / Ягодный / Пряный / Имбирный / Травяной', 'price': '270-330 ₽'},
      ]},
      {'category': '🍰 Домашние десерты', 'items': [
        {'name': 'Шоколадный флан', 'description': 'с мороженым', 'price': '480 ₽'},
        {'name': 'Чизкейк Нью-Йорк', 'description': 'с ягодным соусом', 'price': '480 ₽'},
        {'name': 'Штрудель яблочный / грушевый', 'description': 'с мороженым', 'price': '480 ₽'},
        {'name': 'Мороженое с топпингом', 'description': 'шоколад/клубника/карамель', 'price': '250 ₽'},
        {'name': 'Тирамису / Медовик', 'description': 'классические рецепты', 'price': '500 ₽'},
      ]},
    ];

    for (final category in menuData) {
      for (final item in category['items'] as List) {
        _menuItems.add({
          'id': _uuid.v4(),
          'category': category['category'],
          'name': item['name'],
          'description': item['description'],
          'price': item['price'],
          'note': null,
          'isActive': true,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  // ← НОВОЕ: Инициализация тестовых событий
  static void _initializeEvents() {
    _events.addAll([
      {
        'id': _uuid.v4(),
        'title': 'Stand Up вечер',
        'date': '25.04.2026',
        'time': '20:00',
        'description': 'Живой юмор и отличная компания',
        'icon': 'music_note',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': _uuid.v4(),
        'title': 'Квиз «Знатоки»',
        'date': '27.04.2026',
        'time': '19:30',
        'description': 'Интеллектуальная битва за призы',
        'icon': 'quiz',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': _uuid.v4(),
        'title': 'Трансляция матча',
        'date': '28.04.2026',
        'time': '21:00',
        'description': 'Большой экран, атмосфера болельщиков',
        'icon': 'sports_soccer',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
    ]);
  }

  // === Users ===
  static Response getAllUsers(Request request) {
    final list = _users.values.map((u) => Map<String, dynamic>.from(u)).toList();
    return _jsonListResponse(200, list);
  }

  static Response getUsers(Request request) {
    final list = _users.values.where((u) => u['role'] != 'admin').map((u) => Map<String, dynamic>.from(u)).toList();
    return _jsonListResponse(200, list);
  }

  static Response getUser(Request request, String id) {
    final user = _users[id];
    if (user == null) return _jsonResponse(404, {'error': 'User not found'});
    return _jsonResponse(200, Map<String, dynamic>.from(user));
  }

  static Future<Response> register(Request request) async {
    try {
      final data = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final phone = data['phone']?.toString() ?? '';
      final role = data['role']?.toString() ?? 'user';
      if (role == 'admin') {
        final adminId = data['adminId']?.toString();
        if (adminId == null || _users[adminId]?['role'] != 'admin') {
          return _jsonResponse(403, {'error': 'Только админ может создавать админов'});
        }
      }
      if (_users.values.any((u) => u['phone'] == phone)) {
        return _jsonResponse(400, {'error': 'Телефон уже зарегистрирован'});
      }
      final userId = _uuid.v4().substring(0, 5);
      final salt = _generateSalt();
      _users[userId] = {
        'userId': userId, 'phone': phone,
        'firstName': data['firstName'] ?? '', 'lastName': data['lastName'] ?? '',
        'passwordHash': _hashPassword(data['password'] ?? '', salt), 'salt': salt,
        'role': role, 'totalSpent': 0.0, 'status': 'Start', 'discount': 0,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await _saveToFile();
      return _jsonResponse(200, {'success': true, 'userId': userId, 'role': role});
    } catch (e) {
      return _jsonResponse(500, {'error': 'Ошибка: $e'});
    }
  }

  static Future<Response> login(Request request) async {
    try {
      final data = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final phone = data['phone']?.toString() ?? '';
      final user = _users.values.firstWhere((u) => u['phone'] == phone, orElse: () => {});
      if (user.isEmpty) return _jsonResponse(401, {'error': 'Пользователь не найден'});
      if (_hashPassword(data['password'] ?? '', user['salt']) != user['passwordHash']) {
        return _jsonResponse(401, {'error': 'Неверный пароль'});
      }
      return _jsonResponse(200, {'success': true, 'user': Map<String, dynamic>.from(user)});
    } catch (e) {
      return _jsonResponse(500, {'error': 'Ошибка: $e'});
    }
  }

  static Future<Response> updateUserRole(Request request, String userId) async {
    try {
      if (!_users.containsKey(userId)) return _jsonResponse(404, {'error': 'User not found'});
      final data = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final newRole = data['role']?.toString();
      final changedBy = data['changedBy']?.toString();
      if (changedBy != null && _users[changedBy]?['role'] != 'admin') {
        return _jsonResponse(403, {'error': 'Нет доступа'});
      }
      if (newRole != 'admin' && newRole != 'user') return _jsonResponse(400, {'error': 'Недопустимая роль'});
      final user = _users[userId]!;
      user['role'] = newRole;
      user['roleChangedAt'] = DateTime.now().toIso8601String();
      await _saveToFile();
      return _jsonResponse(200, {'success': true, 'user': Map<String, dynamic>.from(user)});
    } catch (e) {
      return _jsonResponse(500, {'error': 'Ошибка: $e'});
    }
  }

  static Future<Response> updateUser(Request request, String userId) async {
    try {
      if (!_users.containsKey(userId)) return _jsonResponse(404, {'error': 'User not found'});
      final data = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final user = _users[userId]!;
      if (data['firstName'] != null) user['firstName'] = data['firstName'];
      if (data['lastName'] != null) user['lastName'] = data['lastName'];
      if (data['phone'] != null) user['phone'] = data['phone'];
      if (data['password'] != null && data['password'].toString().isNotEmpty) {
        final salt = _generateSalt();
        user['passwordHash'] = _hashPassword(data['password'].toString(), salt);
        user['salt'] = salt;
        user['mustChangePassword'] = false;
      }
      await _saveToFile();
      return _jsonResponse(200, {'success': true, 'user': Map<String, dynamic>.from(user)});
    } catch (e) {
      return _jsonResponse(500, {'error': 'Ошибка: $e'});
    }
  }

  // === Menu CRUD ===
  static Response getMenuItems(Request request) {
    final activeOnly = request.url.queryParameters['active'] == 'true';
    final items = activeOnly ? _menuItems.where((m) => m['isActive'] == true).toList() : _menuItems;
    return _jsonListResponse(200, items);
  }

  static Future<Response> createMenuItem(Request request) async {
    try {
      final data = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final item = {
        'id': _uuid.v4(),
        'category': data['category'],
        'name': data['name'],
        'description': data['description'],
        'price': data['price'],
        'note': data['note'],
        'isActive': data['isActive'] ?? true,
        'createdAt': DateTime.now().toIso8601String(),
      };
      _menuItems.add(item);
      await _saveToFile();
      return _jsonResponse(201, item);
    } catch (e) {
      return _jsonResponse(500, {'error': 'Ошибка создания: $e'});
    }
  }

  static Future<Response> updateMenuItem(Request request, String id) async {
    try {
      final index = _menuItems.indexWhere((m) => m['id'] == id);
      if (index == -1) return _jsonResponse(404, {'error': 'Не найдено'});
      final data = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      _menuItems[index] = {..._menuItems[index], ...data, 'updatedAt': DateTime.now().toIso8601String()};
      await _saveToFile();
      return _jsonResponse(200, _menuItems[index]);
    } catch (e) {
      return _jsonResponse(500, {'error': 'Ошибка обновления: $e'});
    }
  }

  static Future<Response> deleteMenuItem(Request request, String id) async {
    final index = _menuItems.indexWhere((m) => m['id'] == id);
    if (index == -1) return _jsonResponse(404, {'error': 'Не найдено'});
    _menuItems.removeAt(index);
    await _saveToFile();
    return _jsonResponse(200, {'success': true});
  }

  // === Events CRUD ===
  static Response getEvents(Request request) {
    final activeOnly = request.url.queryParameters['active'] == 'true';
    final events = activeOnly 
        ? _events.where((e) => e['isActive'] == true).toList()
        : _events;
    return _jsonListResponse(200, events);
  }

  static Future<Response> createEvent(Request request) async {
    try {
      final data = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final event = {
        'id': _uuid.v4(),
        'title': data['title'],
        'date': data['date'],
        'time': data['time'],
        'description': data['description'],
        'icon': data['icon'] ?? 'event',
        'isActive': data['isActive'] ?? true,
        'createdAt': DateTime.now().toIso8601String(),
      };
      _events.add(event);
      await _saveToFile();
      return _jsonResponse(201, event);
    } catch (e) {
      return _jsonResponse(500, {'error': 'Ошибка создания: $e'});
    }
  }

  static Future<Response> updateEvent(Request request, String id) async {
    try {
      final index = _events.indexWhere((e) => e['id'] == id);
      if (index == -1) return _jsonResponse(404, {'error': 'Не найдено'});
      
      final data = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      _events[index] = {
        ..._events[index],
        ...data,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await _saveToFile();
      return _jsonResponse(200, _events[index]);
    } catch (e) {
      return _jsonResponse(500, {'error': 'Ошибка обновления: $e'});
    }
  }

  static Future<Response> deleteEvent(Request request, String id) async {
    final index = _events.indexWhere((e) => e['id'] == id);
    if (index == -1) return _jsonResponse(404, {'error': 'Не найдено'});
    
    _events.removeAt(index);
    await _saveToFile();
    return _jsonResponse(200, {'success': true});
  }

  // === Purchases ===
  static Future<Response> addPurchase(Request request) async {
    try {
      final data = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final userId = data['userId']?.toString();
      final amount = (data['amount'] as num?)?.toDouble() ?? 0;
      if (userId == null || amount <= 0) return _jsonResponse(400, {'error': 'Некорректные данные'});
      if (!_users.containsKey(userId)) return _jsonResponse(404, {'error': 'User not found'});
      final user = _users[userId]!;
      final discount = user['discount'] as int;
      final finalAmount = amount * (1 - discount / 100);
      user['totalSpent'] = (user['totalSpent'] as double) + amount;
      _updateUserStatus(user);
      _transactions.add({
        'id': _uuid.v4(), 'userId': userId, 'amount': amount,
        'discountApplied': discount, 'finalAmount': finalAmount,
        'createdAt': DateTime.now().toIso8601String(),
      });
      await _saveToFile();
      return _jsonResponse(200, {'success': true, 'user': Map<String, dynamic>.from(user)});
    } catch (e) {
      return _jsonResponse(500, {'error': 'Ошибка: $e'});
    }
  }

  static Response getUserTransactions(Request request, String userId) {
    final list = _transactions.where((t) => t['userId'] == userId)
        .map((t) => Map<String, dynamic>.from(t)).toList()
      ..sort((a, b) => b['createdAt'].toString().compareTo(a['createdAt'].toString()));
    return _jsonListResponse(200, list);
  }

  static void _updateUserStatus(Map<String, dynamic> user) {
    final totalSpent = user['totalSpent'] as double;
    String newStatus = 'Start'; int newDiscount = 0;
    final levels = {
      'Start': {'minSpent': 0, 'discount': 0},
      'Bronze': {'minSpent': 40000, 'discount': 5},
      'Silver': {'minSpent': 60000, 'discount': 10},
      'Gold': {'minSpent': 75000, 'discount': 15},
    };
    for (final entry in levels.entries) {
      if (totalSpent >= (entry.value['minSpent'] as num)) {
        newStatus = entry.key;
        newDiscount = entry.value['discount'] as int;
      }
    }
    user['status'] = newStatus;
    user['discount'] = newDiscount;
  }

  // === Статистика ===
  static Response getStats(Request request) {
    final totalUsers = _users.values.where((u) => u['role'] == 'user').length;
    final totalAdmins = _users.values.where((u) => u['role'] == 'admin').length;
    final totalRevenue = _users.values.fold<double>(0, (sum, u) => sum + (u['totalSpent'] as double));
    return _jsonResponse(200, {
      'totalUsers': totalUsers,
      'totalAdmins': totalAdmins,
      'totalRevenue': totalRevenue,
      'totalTransactions': _transactions.length,
    });
  }

  static String? get dbPath => _dbPath;
}