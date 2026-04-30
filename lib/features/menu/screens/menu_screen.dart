import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _menuData = [
    {'category': '🥗 Холодные закуски и Салаты', 'items': [
      {'name': 'Сырное плато', 'desc': 'горгонзола/бри/пармезан/чеддер', 'price': '370/1250 ₽'},
      {'name': 'Мясное ассорти', 'desc': 'бастурма/салями/куриный рулет/ростбиф', 'price': '320/1350 ₽'},
      {'name': 'Овощное ассорти', 'desc': 'огурцы/томаты/сельдерей/морковь/перец/соус тар-тар', 'price': '420/850 ₽'},
      {'name': 'Брускетта с лососем', 'desc': 'лосось/авокадо/крем-сыр/огурец/томаты', 'price': '210/800 ₽'},
      {'name': 'Брускетта с крабом', 'desc': 'краб/томат/зеленый салат/крем-сыр', 'price': '200/750 ₽'},
      {'name': 'Тар-Тар из лосося', 'desc': 'лосось/авокадо/огурец/каперсы/лук/перец', 'price': '220/800 ₽'},
      {'name': 'Тар-тар из тунца', 'desc': 'тунец/авокадо/огурец/каперсы/лук/перец', 'price': '220/780 ₽'},
      {'name': 'Тар-тар из говядины', 'desc': 'говядина/лук/соленый огурец/желток/каперсы', 'price': '230/800 ₽'},
      {'name': 'Цезарь с курицей', 'desc': 'листья салата/курица/черри/сухарики/соус цезарь', 'price': '230/750 ₽'},
      {'name': 'Цезарь с креветками', 'desc': 'листья салата/креветки/черри/сухарики/соус цезарь', 'price': '230/790 ₽'},
      {'name': 'Греческий салат', 'desc': 'огурцы/томаты/оливки/фетакса/перец/лук', 'price': '240/650 ₽'},
      {'name': 'Нисуаз с тунцом', 'desc': 'салат айсберг/маслины/картофель/тунец/яйцо/черри', 'price': '240/800 ₽'},
      {'name': 'Салат с хрустящими баклажанами', 'desc': 'баклажаны фри/томаты/кинза/заправка', 'price': '245/680 ₽'},
      {'name': 'Теплый морской салат', 'desc': 'ассорти из морепродуктов/томаты/салатные листья/заправка', 'price': '250/890 ₽'},
      {'name': 'Авокадо с креветками', 'desc': 'авокадо/томаты/креветки/листья салата/соус песто', 'price': '200/850 ₽'},
      {'name': 'Теплый салат с куриной печенью', 'desc': 'руккола/романо/айсберг/куриная печень/грейпфрут', 'price': '245/750 ₽'},
    ]},
    {'category': '🔥 Горячие закуски и Сеты', 'items': [
      {'name': 'Жареный сулугуни', 'desc': 'сулугуни/кунжут/ягодный соус', 'price': '265/700 ₽'},
      {'name': 'Домашние чесночные гренки', 'desc': 'гренки/чесночное масло/соус тар-тар', 'price': '200/450 ₽'},
      {'name': 'Креветки Васаби', 'desc': 'креветки Ваннамей/соус васаби', 'price': '190/650 ₽'},
      {'name': 'Креветки на гриле', 'desc': 'креветки Ваннамей/лайм/кисло-сладкий соус', 'price': '200/790 ₽'},
      {'name': 'Картофель фри / Батат фри', 'desc': 'с пармезаном', 'price': '150/350 ₽'},
      {'name': 'Картофель по-деревенски', 'desc': 'запеченный со специями', 'price': '150/350 ₽'},
      {'name': 'Луковые кольца', 'desc': '6 шт', 'price': '300 ₽'},
      {'name': 'Кольца кальмара', 'desc': '6 шт', 'price': '380 ₽'},
      {'name': 'Сырные палочки', 'desc': 'из моцареллы, 6 шт', 'price': '400 ₽'},
      {'name': 'Куриные крылышки / BBQ', 'desc': '5 шт', 'price': '450 ₽'},
      {'name': 'Наггетсы / Стрипсы', 'desc': '6 шт / 5 шт', 'price': '400 ₽'},
      {'name': 'Сет №1', 'desc': 'крылышки/фри/луковые кольца', 'price': '320/950 ₽'},
      {'name': 'Сет №2', 'desc': 'сырные палочки/кольца/стрипсы/фри', 'price': '380/1250 ₽'},
      {'name': 'Сет №3', 'desc': 'креветки/кольца кальмара/картофель', 'price': '325/1150 ₽'},
      {'name': 'Сет №4', 'desc': 'наггетсы/сырные палочки/картофель', 'price': '320/990 ₽'},
      {'name': 'Сет на компанию', 'desc': 'крылышки/картофель 2 вида/кольца/сырные палочки/кальмары', 'price': '560/1650 ₽'},
    ]},
    {'category': '🍔 Бургеры и Роллы', 'note': '* Все блюда подаются с картофелем фри', 'items': [
      {'name': 'Блю Чиз бургер', 'desc': 'котлета из мраморной говядины/соус блю чиз/салат/лук/томаты', 'price': '410/750 ₽'},
      {'name': 'Итальянский бургер', 'desc': 'говядина/перец на гриле/лук/томаты/пармезан/салат', 'price': '410/750 ₽'},
      {'name': 'Бургер со стрипсами', 'desc': 'куриные стрипсы/огурчик/соус/сыр/салат/томаты', 'price': '390/650 ₽'},
      {'name': 'Ролл с говядиной', 'desc': 'лепешка/вырезка/томаты/лук/салат/сыр', 'price': '380/690 ₽'},
      {'name': 'Ролл с курицей', 'desc': 'лепешка/грудка/томаты/лук/салат/сыр', 'price': '380/650 ₽'},
      {'name': 'Клаб-сэндвич', 'desc': 'Тосты/куриная грудка/томаты/лук/салат/сыр', 'price': '390/700 ₽'},
    ]},
    {'category': '🍕 Пицца 30 см', 'note': '** Вся пицца из домашнего теста, свежих продуктов, выпекается в печи', 'items': [
      {'name': 'Маргарита', 'desc': 'домашнее тесто/соус песто/сыр', 'price': '750 ₽'},
      {'name': 'Четыре сыра', 'desc': 'пармезан/моцарелла/горгонзола/чеддер', 'price': '850 ₽'},
      {'name': 'Пепперони', 'desc': 'соус/пепперони/сыр', 'price': '850 ₽'},
      {'name': 'Барбекью', 'desc': 'сыр/соус/красный лук/бекон/грибы', 'price': '850 ₽'},
      {'name': 'Пицца с цыпленком', 'desc': 'сыр/соус/мясо цыпленка/томаты', 'price': '850 ₽'},
      {'name': 'Пицца «Цезарь»', 'desc': 'соус цезарь/пармезан/куриная грудка/листья салата', 'price': '850 ₽'},
      {'name': 'Пицца с морепродуктами', 'desc': 'соус/кальмары/креветки/пармезан', 'price': '950 ₽'},
    ]},
    {'category': '🍝 Паста', 'items': [
      {'name': 'Карбонара', 'desc': 'спагетти/бекон/пармезан/сливки', 'price': '290/700 ₽'},
      {'name': 'Пенне с курицей и грибами', 'desc': 'пенне/курица/шампиньоны/пармезан/сливочный соус', 'price': '290/700 ₽'},
      {'name': 'Паста с креветками', 'desc': 'паста/томатно-сливочный соус/креветки/пармезан', 'price': '280/750 ₽'},
      {'name': 'Паста с томатным соусом', 'desc': 'пенне/томатный соус/базилик', 'price': '270/650 ₽'},
      {'name': 'Паста с морепродуктами', 'desc': 'спагетти/томатный соус/креветки/мидии', 'price': '270/850 ₽'},
    ]},
    {'category': '🥘 Супы и Выпечка', 'items': [
      {'name': 'Том Ям', 'desc': 'подается с рисом', 'price': '400/850 ₽'},
      {'name': 'Куриный суп с лапшой', 'desc': 'бульон/лапша/яйцо', 'price': '400/850 ₽'},
      {'name': 'Борщ с говядиной', 'desc': 'подается со сметаной и гренками', 'price': '390/750 ₽'},
      {'name': 'Харчо', 'desc': 'с говядиной', 'price': '350/450 ₽'},
      {'name': 'Хачапури по-аджарски', 'desc': 'домашнее тесто/сыр/яйцо', 'price': '360/600 ₽'},
      {'name': 'Хачапури по-мегрельски', 'desc': 'домашнее тесто/сыр', 'price': '350/600 ₽'},
    ]},
    {'category': '🦪 Мидии', 'items': [
      {'name': 'Мидии в соусе блю чиз', 'desc': 'мидии в створках/соус блю чиз', 'price': '490/700 ₽'},
      {'name': 'Мидии в томатном соусе', 'desc': 'мидии в створках/томатный соус', 'price': '580/750 ₽'},
    ]},
    {'category': '🥩 Горячие блюда', 'items': [
      {'name': 'Чипсы', 'desc': 'сырные/с солью/лук/сметана и зелень', 'price': '290/890 ₽'},
      {'name': 'Сыр Чечил копченый', 'desc': '', 'price': '290/950 ₽'},
      {'name': 'Арахис / Фисташки', 'desc': '', 'price': '320/800 ₽'},
      {'name': 'Манты', 'desc': 'традиционные, с соусом тар-тар и аджикой', 'price': '290/790 ₽'},
      {'name': 'Люля из курицы', 'desc': 'куриный люля/картофель', 'price': '200/1100 ₽'},
      {'name': 'Люля из говядины', 'desc': 'люля из говядины/овощной салат', 'price': '290/950 ₽'},
      {'name': 'Корейка баранины на гриле', 'desc': 'корейка, лаваш, маринованный лук', 'price': '320/750 ₽'},
      {'name': 'Стейк тунца', 'desc': 'тунец/картофель/соус', 'price': '310/500 ₽'},
      {'name': 'Бефстроганов', 'desc': 'картофельное пюре/говядина/лук/соус', 'price': '310/750 ₽'},
      {'name': 'Шашлык из курицы', 'desc': 'подается с салатом и соусом', 'price': '310/650 ₽'},
      {'name': 'Стейк Форели / Филе миньон', 'desc': 'на гриле', 'price': '330/600 ₽'},
      {'name': 'Сковорода СССР', 'desc': 'говядина/шампиньоны/помидоры/лук/сыр чеддер', 'price': '325/650 ₽'},
      {'name': 'Овощи гриль', 'desc': 'баклажаны/кабачки/шампиньоны', 'price': '320/790 ₽'},
      {'name': 'Говядина в азиатском стиле', 'desc': 'говядина/перец/морковь/огурцы/лук/азиатский соус/рис', 'price': '290/890 ₽'},
      {'name': 'Говядина с картошкой и грибами', 'desc': 'говядина/лук/картофель/шампиньоны/специи', 'price': '290/950 ₽'},
      {'name': 'Удон с курицей или говядиной', 'desc': '', 'price': '320/800 ₽'},
    ]},
    {'category': '🍹 Напитки и Чай', 'items': [
      {'name': 'Домашний лимонад', 'desc': 'Манго-маракуйя / Цитрусовый / Маракуйя-малина / Грейпфрут-малина / Ягодный / Лаванда-малина / Мохито', 'price': '450/950 ₽'},
      {'name': 'Газировка / Вода / Сок / Фреш', 'desc': 'Кока-кола / Вода / Сок / Апельсиновый / Грейпфрутовый', 'price': '250-450 ₽'},
      {'name': 'Кофе', 'desc': 'Американо / Капучино / Латте / Эспрессо', 'price': '200-250 ₽'},
      {'name': 'Чай классический', 'desc': 'Ассам / Эрл грей / Сенча / Молочный улун / Зеленый с жасмином', 'price': '500/600 ₽ (500/1000 мл)'},
      {'name': 'Нечайный чай (фруктово-ягодный)', 'desc': 'Клюква-имбирь / Лимон-имбирь / Облепиховый / Манго-маракуйя / Ягодный', 'price': '770 ₽ (1000 мл)'},
      {'name': 'Добавки к чаю', 'desc': 'лимон/мята/чабрец/мёд', 'price': '100 ₽'},
    ]},
    {'category': '☕ Паровые коктейли и Кальяны', 'items': [
      {'name': 'Кальян премиум + чай', 'desc': 'Классическая чаша / Грейпфрут / Гранат / Ананас / Сигарный табак', 'price': '1900-2800 ₽'},
      {'name': 'Кальянный ланч', 'desc': 'Кальян премиум + чай зеленый/черный', 'price': '1800 ₽'},
      {'name': 'Паровые коктейли', 'desc': 'Облепиховый / Цитрусовый / Ягодный / Пряный / Имбирный / Травяной', 'price': '270-330 ₽'},
    ]},
    {'category': '🍰 Домашние десерты', 'note': '* Все десерты выполнены вручную из натуральных ингредиентов', 'items': [
      {'name': 'Шоколадный флан', 'desc': 'с мороженым', 'price': '480 ₽'},
      {'name': 'Чизкейк Нью-Йорк', 'desc': 'с ягодным соусом', 'price': '480 ₽'},
      {'name': 'Штрудель яблочный / грушевый', 'desc': 'с мороженым', 'price': '480 ₽'},
      {'name': 'Мороженое с топпингом', 'desc': 'шоколад/клубника/карамель', 'price': '250 ₽'},
      {'name': 'Тирамису / Медовик', 'desc': 'классические рецепты', 'price': '500 ₽'},
    ]},
  ];

  List<Map<String, dynamic>> _getFilteredData() {
    if (_searchQuery.isEmpty) return _menuData;
    final query = _searchQuery.toLowerCase();
    final List<Map<String, dynamic>> results = [];
    for (var category in _menuData) {
      final catName = category['category'].toString().toLowerCase();
      if (catName.contains(query)) { results.add(category); continue; }
      final matchedItems = (category['items'] as List).where((item) {
        return item['name'].toString().toLowerCase().contains(query) ||
               item['desc'].toString().toLowerCase().contains(query) ||
               item['price'].toString().toLowerCase().contains(query);
      }).toList();
      if (matchedItems.isNotEmpty) results.add({'category': category['category'], 'items': matchedItems});
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 360;
    final padding = EdgeInsets.symmetric(horizontal: isSmall ? 8 : 12);
    final itemPad = EdgeInsets.symmetric(horizontal: isSmall ? 10 : 16, vertical: 8);
    final tSize = isSmall ? 14.0 : 15.0;
    final dSize = isSmall ? 11.0 : 12.0;
    final pSize = isSmall ? 13.0 : 14.0;

    final filtered = _getFilteredData();
    final searching = _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Меню'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                labelText: 'Поиск блюд...',
                hintText: 'Например: паста, сыр, лимонад',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searching ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); }) : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                isDense: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(searching ? 'Ничего не найдено' : 'Загрузка...', style: TextStyle(color: Colors.grey[600])),
                    if (searching) TextButton(onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); }, child: const Text('Очистить')),
                  ]))
                : ListView.builder(
                    padding: padding.copyWith(bottom: 80),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final sec = filtered[i];
                      final cat = sec['category'] as String;
                      final items = sec['items'] as List;
                      final note = sec['note'] as String?;
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          padding: itemPad, margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [
                            Text(cat, style: TextStyle(fontSize: isSmall ? 15 : 17, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            if (note != null) ...[const SizedBox(width: 6), Icon(Icons.info_outline, size: 14, color: Colors.grey[600])],
                          ]),
                        ),
                        if (note != null) Padding(padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4), child: Text(note, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic))),
                        ...items.map((it) => Card(
                          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4), elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: itemPad,
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(it['name'], style: TextStyle(fontSize: tSize, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                                if (it['desc'].toString().isNotEmpty) ...[const SizedBox(height: 4), Text(it['desc'], style: TextStyle(fontSize: dSize, color: Colors.grey[600], height: 1.3), maxLines: 3, overflow: TextOverflow.ellipsis)],
                              ])),
                              const SizedBox(width: 12),
                              Text(it['price'], style: TextStyle(fontSize: pSize, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ]),
                          ),
                        )).toList(),
                      ]);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }
}