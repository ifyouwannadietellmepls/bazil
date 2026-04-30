import '../models/dish_model.dart';

class MenuData {
  static const categories = [
    'cold_snacks',
    'salads',
    'hot_snacks',
    'beer_sets',
    'burgers',
    'pizza',
    'pasta',
    'mussels',
    'soups',
    'bakery',
    'hot_dishes',
    'beer_snacks',
    'drinks',
    'desserts',
  ];

  static String getCategoryName(String key) {
    switch (key) {
      case 'cold_snacks': return 'Холодные закуски';
      case 'salads': return 'Салаты';
      case 'hot_snacks': return 'Горячие закуски';
      case 'beer_sets': return 'Сеты к пиву';
      case 'burgers': return 'Бургеры и роллы';
      case 'pizza': return 'Пицца 30 см';
      case 'pasta': return 'Паста';
      case 'mussels': return 'Мидии';
      case 'soups': return 'Супы';
      case 'bakery': return 'Выпечка';
      case 'hot_dishes': return 'Горячие блюда';
      case 'beer_snacks': return 'Закуски к пиву';
      case 'drinks': return 'Напитки';
      case 'desserts': return 'Десерты';
      default: return key;
    }
  }

  static final allDishes = <Dish>[
    // === ХОЛОДНЫЕ ЗАКУСКИ ===
    const Dish(id: 'cheese_plate', name: 'Сырное плато', description: 'горгонзола/бри/пармезан/чеддер', weight: 370, price: 1250, category: 'cold_snacks'),
    const Dish(id: 'meat_assortment', name: 'Мясное ассорти', description: 'бастурма/салями/куриный рулет/ростбиф', weight: 320, price: 1350, category: 'cold_snacks'),
    const Dish(id: 'veg_assortment', name: 'Овощное ассорти', description: 'огурцы/томаты/сельдерей/морковь/перец/соус тар-тар', weight: 420, price: 850, category: 'cold_snacks', tags: ['vegetarian']),
    const Dish(id: 'bruschetta_salmon', name: 'Брускетта с лососем', description: 'лосось/авокадо/крем-сыр/огурец/томаты', weight: 210, price: 800, category: 'cold_snacks'),
    const Dish(id: 'bruschetta_crab', name: 'Брускетта с крабом', description: 'краб/томат/зеленый салат/крем-сыр', weight: 200, price: 750, category: 'cold_snacks'),
    const Dish(id: 'tartar_salmon', name: 'Тар-Тар из лосося', description: 'лосось/авокадо/огурец/каперсы/лук/перец', weight: 230, price: 800, category: 'cold_snacks'),
    const Dish(id: 'tartar_tuna', name: 'Тар-тар из тунца', description: 'тунец/авокадо/огурец/каперсы/лук/перец', weight: 230, price: 750, category: 'cold_snacks'),
    const Dish(id: 'tartar_beef', name: 'Тар-тар из говядины', description: 'говядина/лук/соленый огурец/желток/каперсы', weight: 230, price: 790, category: 'cold_snacks'),

    // === САЛАТЫ ===
    const Dish(id: 'caesar_chicken', name: 'Цезарь с курицей', description: 'листья салата/курица/черри/сухарики/соус цезарь', weight: 240, price: 650, category: 'salads', tags: ['popular']),
    const Dish(id: 'caesar_shrimp', name: 'Цезарь с креветками', description: 'листья салата/креветки/черри/сухарики/соус цезарь', weight: 240, price: 800, category: 'salads'),
    const Dish(id: 'greek_salad', name: 'Греческий салат', description: 'огурцы/томаты/оливки/фетакса/перец/лук', weight: 245, price: 680, category: 'salads', tags: ['vegetarian']),
    const Dish(id: 'nicoise_tuna', name: 'Нисуаз с тунцом', description: 'салат айсберг/маслины/картофель/тунец/яйцо/черри', weight: 250, price: 890, category: 'salads'),
    const Dish(id: 'eggplant_salad', name: 'Салат с хрустящими баклажанами', description: 'баклажаны фри/томаты/кинза/заправка', weight: 200, price: 850, category: 'salads', tags: ['vegetarian']),
    const Dish(id: 'seafood_warm_salad', name: 'Теплый морской салат', description: 'ассорти из морепродуктов/томаты/салатные листья/заправка', weight: 245, price: 750, category: 'salads'),
    const Dish(id: 'avocado_shrimp', name: 'Авокадо с креветками', description: 'авокадо/томаты/креветки/листья салата/соус песто', weight: 220, price: 800, category: 'salads'),
    const Dish(id: 'liver_warm_salad', name: 'Теплый салат с куриной печенью', description: 'руккола/романо/айсберг/куриная печень/грейпфрут', weight: 220, price: 780, category: 'salads'),

    // === ГОРЯЧИЕ ЗАКУСКИ ===
    const Dish(id: 'suluguni_fried', name: 'Жареный сулугуни с ягодным соусом', description: 'сулугуни/кунжут/ягодный соус', weight: 265, price: 700, category: 'hot_snacks'),
    const Dish(id: 'garlic_croutons', name: 'Домашние чесночные гренки', description: 'гренки/чесночное масло/соус тар-тар', weight: 200, price: 450, category: 'hot_snacks'),
    const Dish(id: 'shrimp_wasabi', name: 'Креветки Васаби', description: 'креветки Ваннамей/соус васаби', weight: 190, price: 650, category: 'hot_snacks', tags: ['spicy']),
    const Dish(id: 'shrimp_grill', name: 'Креветки на гриле', description: 'креветки Ваннамей/лайм/кисло-сладкий соус', weight: 200, price: 790, category: 'hot_snacks'),
    const Dish(id: 'fries', name: 'Картофель фри', description: '', weight: 150, price: 350, category: 'hot_snacks', tags: ['vegetarian']),
    const Dish(id: 'sweet_potato_fries', name: 'Батат фри с пармезаном', description: '', weight: 150, price: 450, category: 'hot_snacks', tags: ['vegetarian']),
    const Dish(id: 'country_potatoes', name: 'Картофель по-деревенски', description: '', weight: 150, price: 350, category: 'hot_snacks', tags: ['vegetarian']),
    const Dish(id: 'onion_rings', name: 'Луковые кольца', description: '', weight: 150, price: 300, category: 'hot_snacks', tags: ['vegetarian']),
    const Dish(id: 'calamari_rings', name: 'Кольца кальмара', description: '', weight: 150, price: 380, category: 'hot_snacks'),
    const Dish(id: 'cheese_sticks', name: 'Сырные палочки из моцареллы', description: '', weight: 150, price: 400, category: 'hot_snacks', tags: ['vegetarian']),
    const Dish(id: 'chicken_wings', name: 'Куриные крылышки', description: '', weight: 200, price: 450, category: 'hot_snacks'),
    const Dish(id: 'chicken_wings_bbq', name: 'Куриные крылышки BBQ', description: '', weight: 200, price: 450, category: 'hot_snacks'),
    const Dish(id: 'nuggets', name: 'Наггетсы', description: '6 шт', weight: 180, price: 400, category: 'hot_snacks'),
    const Dish(id: 'chicken_strips', name: 'Стрипсы из куриной грудки', description: '5 шт', weight: 175, price: 450, category: 'hot_snacks'),

    // === СЕТЫ К ПИВУ ===
    const Dish(id: 'beer_set_1', name: 'Сет №1', description: 'куриные крылышки/картофель фри/луковые кольца', weight: 320, price: 950, category: 'beer_sets'),
    const Dish(id: 'beer_set_2', name: 'Сет №2', description: 'сырные палочки/луковые кольца/стрипсы/картофель фри', weight: 380, price: 1250, category: 'beer_sets'),
    const Dish(id: 'beer_set_3', name: 'Сет №3', description: 'креветки/кольца кальмара/картофель по-деревенски', weight: 325, price: 1150, category: 'beer_sets'),
    const Dish(id: 'beer_set_4', name: 'Сет №4', description: 'наггетсы/сырные палочки/картофель по-деревенски', weight: 320, price: 990, category: 'beer_sets'),
    const Dish(id: 'beer_set_company', name: 'Сет на компанию', description: 'куриные крылышки/картофель 2 вида/луковые кольца/сырные палочки/кольца кальмара', weight: 560, price: 1650, category: 'beer_sets'),

    // === БУРГЕРЫ И РОЛЛЫ ===
    const Dish(id: 'blue_cheese_burger', name: 'Блю Чиз бургер', description: 'булочки/котлета из мраморной говядины/соус блю чиз/салат/лук/томаты/маринованный огурчик', weight: 410, price: 750, category: 'burgers'),
    const Dish(id: 'italian_burger', name: 'Итальянский бургер', description: 'булочки/котлета из мраморной говядины/перец на гриле/лук/томаты/пармезан/салат', weight: 410, price: 750, category: 'burgers'),
    const Dish(id: 'chicken_strips_burger', name: 'Бургер с куриными стрипсами', description: 'булочки/куриные стрипсы/маринованный огурчик/соус/сыр/салат/томаты', weight: 390, price: 650, category: 'burgers'),
    const Dish(id: 'beef_roll', name: 'Ролл с говядиной', description: 'лепешка/вырезка из говядины/томаты/лук/салат/сыр', weight: 380, price: 690, category: 'burgers'),
    const Dish(id: 'chicken_roll', name: 'Ролл с курицей', description: 'лепешка/куриная грудка/томаты/лук/салат/сыр', weight: 380, price: 650, category: 'burgers'),
    const Dish(id: 'club_sandwich', name: 'Клаб-сэндвич', description: 'тосты/куриная грудка/томаты/лук/салат/сыр', weight: 390, price: 700, category: 'burgers'),

    // === ПИЦЦА 30 см ===
    const Dish(id: 'pizza_margarita', name: 'Маргарита', description: 'домашнее тесто/соус песто/сыр', weight: 0, price: 750, category: 'pizza', tags: ['vegetarian']),
    const Dish(id: 'pizza_four_cheese', name: 'Четыре сыра', description: 'домашнее тесто/пармезан/моцарелла/горгонзола/чеддер', weight: 0, price: 850, category: 'pizza', tags: ['vegetarian']),
    const Dish(id: 'pizza_pepperoni', name: 'Пепперони', description: 'домашнее тесто/соус/пепперони/сыр', weight: 0, price: 850, category: 'pizza'),
    const Dish(id: 'pizza_bbq', name: 'Барбекью', description: 'домашнее тесто/сыр/соус/красный лук/бекон/грибы', weight: 0, price: 850, category: 'pizza'),
    const Dish(id: 'pizza_chicken', name: 'Пицца с цыпленком', description: 'домашнее тесто/сыр/соус/мясо цыпленка/томаты', weight: 0, price: 850, category: 'pizza'),
    const Dish(id: 'pizza_caesar', name: 'Пицца «Цезарь»', description: 'домашнее тесто/соус цезарь/пармезан/куриная грудка/листья салата', weight: 0, price: 850, category: 'pizza'),
    const Dish(id: 'pizza_seafood', name: 'Пицца с морепродуктами', description: 'домашнее тесто/соус/кальмары/креветки/пармезан', weight: 0, price: 950, category: 'pizza'),

    // === ПАСТА ===
    const Dish(id: 'pasta_carbonara', name: 'Карбонара', description: 'спагетти/бекон/пармезан/сливки', weight: 290, price: 700, category: 'pasta'),
    const Dish(id: 'pasta_chicken_mushroom', name: 'Пенне с курицей и грибами', description: 'пенне/курица/шампиньоны/пармезан/сливочный соус', weight: 290, price: 700, category: 'pasta'),
    const Dish(id: 'pasta_shrimp', name: 'Паста с креветками', description: 'паста/томатно-сливочный соус/креветки/пармезан', weight: 280, price: 750, category: 'pasta'),
    const Dish(id: 'pasta_tomato_basil', name: 'Паста с томатным соусом и базиликом', description: 'пенне/томатный соус/базилик', weight: 270, price: 650, category: 'pasta', tags: ['vegetarian']),
    const Dish(id: 'pasta_seafood', name: 'Паста с морепродуктами', description: 'спагетти/томатный соус/креветки/мидии', weight: 270, price: 850, category: 'pasta'),

    // === МИДИИ ===
    const Dish(id: 'mussels_blue_cheese', name: 'Мидии в соусе блю чиз', description: 'мидии в створках/соус блю чиз', weight: 400, price: 850, category: 'mussels'),
    const Dish(id: 'mussels_tomato', name: 'Мидии в томатном соусе', description: 'мидии в створках/томатный соус', weight: 400, price: 850, category: 'mussels'),

    // === СУПЫ ===
    const Dish(id: 'soup_tom_yam', name: 'Том Ям', description: 'подается с рисом', weight: 400, price: 850, category: 'soups', tags: ['spicy']),
    const Dish(id: 'soup_chicken_noodle', name: 'Куриный суп с лапшой', description: 'бульон/лапша/яйцо', weight: 400, price: 850, category: 'soups'),
    const Dish(id: 'soup_borscht', name: 'Борщ с говядиной', description: 'подается со сметаной и гренками', weight: 390, price: 750, category: 'soups'),
    const Dish(id: 'soup_kharcho', name: 'Харчо', description: 'с говядиной', weight: 350, price: 450, category: 'soups'),

    // === ВЫПЕЧКА ===
    const Dish(id: 'khachapuri_adjarian', name: 'Хачапури по-аджарски', description: 'домашнее тесто/сыр/яйцо', weight: 360, price: 600, category: 'bakery', tags: ['vegetarian']),
    const Dish(id: 'khachapuri_megrelian', name: 'Хачапури по-мегрельски', description: 'домашнее тесто/сыр', weight: 350, price: 600, category: 'bakery', tags: ['vegetarian']),

    // === ГОРЯЧИЕ БЛЮДА ===
    const Dish(id: 'manti', name: 'Манты', description: 'традиционные манты, подаются с соусом тар-тар и аджикой', weight: 325, price: 650, category: 'hot_dishes'),
    const Dish(id: 'chicken_lula', name: 'Люля из курицы с картофелем', description: 'куриный люля/картофель', weight: 320, price: 790, category: 'hot_dishes'),
    const Dish(id: 'beef_lula', name: 'Люля из говядины', description: 'люля из говядины/овощной салат', weight: 290, price: 890, category: 'hot_dishes'),
    const Dish(id: 'lamb_chops', name: 'Корейка баранины на гриле', description: 'корейка/лаваш/маринованный лук', weight: 290, price: 950, category: 'hot_dishes'),
    const Dish(id: 'tuna_steak', name: 'Стейк тунца с картофельными дольками', description: 'тунец/картофель/соус', weight: 320, price: 800, category: 'hot_dishes'),
    const Dish(id: 'beef_stroganoff', name: 'Бефстроганов', description: 'картофельное пюре/говядина/лук/соус', weight: 350, price: 790, category: 'hot_dishes'),
    const Dish(id: 'chicken_shashlik', name: 'Шашлык из курицы', description: 'подается с салатом и соусом', weight: 290, price: 790, category: 'hot_dishes'),
    const Dish(id: 'trout_steak', name: 'Стейк форели на гриле', description: '', weight: 200, price: 1100, category: 'hot_dishes'),
    const Dish(id: 'filet_mignon', name: 'Филе миньон на гриле', description: 'говядина/картофель', weight: 290, price: 950, category: 'hot_dishes'),
    const Dish(id: 'ussr_skillet', name: 'Сковорода СССР', description: 'говядина/шампиньоны/помидоры/лук/сыр чеддер', weight: 320, price: 750, category: 'hot_dishes'),
    const Dish(id: 'grilled_vegetables', name: 'Овощи гриль', description: 'баклажаны/кабачки/шампиньоны', weight: 310, price: 500, category: 'hot_dishes', tags: ['vegetarian']),
    const Dish(id: 'beef_asian', name: 'Говядина в азиатском стиле с огурцами', description: 'говядина/перец/морковь/огурцы/лук/азиатский соус/рис', weight: 310, price: 750, category: 'hot_dishes'),
    const Dish(id: 'beef_potato_mushroom', name: 'Говядина с картошкой и грибами на сковороде', description: 'говядина/лук/картофель/шампиньоны/специи', weight: 310, price: 650, category: 'hot_dishes'),
    const Dish(id: 'udon', name: 'Удон с курицей или говядиной', description: '', weight: 330, price: 600, category: 'hot_dishes'),

    // === ЗАКУСКИ К ПИВУ ===
    const Dish(id: 'chips', name: 'Чипсы', description: 'на выбор: сырные/с солью/лук/сметана и зелень', weight: 0, price: 350, category: 'beer_snacks', tags: ['vegetarian']),
    const Dish(id: 'chechil_cheese', name: 'Сыр Чечил копченый', description: '', weight: 0, price: 450, category: 'beer_snacks'),
    const Dish(id: 'peanuts', name: 'Арахис', description: '', weight: 0, price: 300, category: 'beer_snacks'),
    const Dish(id: 'pistachios', name: 'Фисташки', description: '', weight: 0, price: 400, category: 'beer_snacks'),
  ];

  static List<Dish> getByCategory(String category) {
    return allDishes.where((dish) => dish.category == category).toList();
  }

  static List<Dish> filterByTags(List<Dish> dishes, List<String> tags) {
    if (tags.isEmpty) return dishes;
    return dishes.where((dish) => tags.every((tag) => dish.tags.contains(tag))).toList();
  }
}