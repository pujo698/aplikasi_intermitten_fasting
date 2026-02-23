class Recipe {
  // Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'instructions': instructions,
      'tags': tags,
      'dietGoals': dietGoals,
      'mealTypes': mealTypes,
      'isHalal': isHalal,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isLowCarb': isLowCarb,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      calories: json['calories'],
      protein: json['protein'],
      fat: json['fat'],
      carbs: json['carbs'],
      imageUrl: json['imageUrl'],
      ingredients: List<String>.from(json['ingredients']),
      instructions: List<String>.from(json['instructions']),
      tags: json['tags'],
      dietGoals: List<String>.from(json['dietGoals'] ?? []),
      mealTypes: List<String>.from(json['mealTypes'] ?? []),
      isHalal: json['isHalal'] ?? true,
      isVegetarian: json['isVegetarian'] ?? false,
      isVegan: json['isVegan'] ?? false,
      isLowCarb: json['isLowCarb'] ?? false,
    );
  }
  
  // existing fields
  final String id;
  final String title;
  final String description;
  final int calories;
  final int protein;
  final int fat;
  final int carbs;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> instructions;
  final String tags; 
  
  // New Fields
  final List<String> dietGoals; // 'fatLoss', 'maintenance', 'muscleGain'
  final List<String> mealTypes; // 'breakfast', 'lunch', 'dinner', 'snack'
  final bool isHalal;
  final bool isVegetarian;
  final bool isVegan;
  final bool isLowCarb;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.tags,
    this.dietGoals = const [],
    this.mealTypes = const [],
    this.isHalal = true,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isLowCarb = false,
  });
}

final List<Recipe> dummyRecipes = [
  Recipe(
    id: '1',
    title: 'Avocado Toast & Egg',
    description: 'Sarapan sehat kaya lemak baik dan protein.',
    calories: 350,
    protein: 12,
    fat: 20,
    carbs: 30,
    imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414395d8?auto=format&fit=crop&w=800&q=80',
    tags: 'Sarapan, Sehat',
    dietGoals: ['fatLoss', 'maintenance'],
    mealTypes: ['breakfast'],
    isHalal: true,
    isVegetarian: true,
    ingredients: [
      '2 lembar roti gandum',
      '1 buah alpukat matang',
      '1 butir telur rebus/ceplok',
      'Garam & lada secukupnya',
      'Sedikit perasan jeruk nipis'
    ],
    instructions: [
      'Panggang roti hingga kecokelatan.',
      'Hancurkan alpukat dengan garpu, beri garam, lada, dan jeruk nipis.',
      'Oleskan alpukat di atas roti.',
      'Tambahkan telur di atasnya. Siap disajikan.'
    ],
  ),
  Recipe(
    id: '2',
    title: 'Grilled Chicken Salad',
    description: 'Makan siang ringan rendah karbohidrat.',
    calories: 400,
    protein: 45,
    fat: 15,
    carbs: 10,
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80',
    tags: 'High Protein, Low Carb',
    dietGoals: ['fatLoss', 'muscleGain'],
    mealTypes: ['lunch', 'dinner'],
    isHalal: true,
    isLowCarb: true,
    ingredients: [
      '200g dada ayam fillet',
      'Mix salad (selada, tomat ceri, timun)',
      '1 sdm minyak zaitun',
      'Dressing favorit (rekomendasi: balsamic vinegar)'
    ],
    instructions: [
      'Bumbui ayam dengan garam & lada, panggang di teflon hingga matang.',
      'Potong-potong ayam.',
      'Campurkan sayuran di mangkuk besar.',
      'Tambahkan ayam dan dressing. Aduk rata.'
    ],
  ),
  Recipe(
    id: '3',
    title: 'Oatmeal Berries',
    description: 'Energi tahan lama untuk berbuka puasa.',
    calories: 300,
    protein: 8,
    fat: 5,
    carbs: 50,
    imageUrl: 'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?auto=format&fit=crop&w=800&q=80',
    tags: 'High Fiber, Vegan',
    dietGoals: ['maintenance', 'muscleGain'],
    mealTypes: ['breakfast', 'snack'],
    isHalal: true,
    isVegetarian: true,
    isVegan: true,
    ingredients: [
      '1/2 cup rolled oats',
      '1 cup susu (almond/sapi)',
      'Segenggam beri (stroberi/blueberry)',
      '1 sdt madu/stevia'
    ],
    instructions: [
      'Masak oat dengan susu hingga mengental.',
      'Tuang ke mangkuk, taburi beri dan madu.',
      'Bisa ditambahkan chia seeds jika ada.'
    ],
  ),
   Recipe(
    id: '4',
    title: 'Salmon Teriyaki',
    description: 'Makan malam mewah kaya omega-3.',
    calories: 500,
    protein: 35,
    fat: 25,
    carbs: 15,
    imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a7270028d?auto=format&fit=crop&w=800&q=80',
    tags: 'High Protein, Healthy Fat',
    dietGoals: ['muscleGain', 'maintenance'],
    mealTypes: ['lunch', 'dinner'],
    isHalal: true,
    isLowCarb: true,
    ingredients: [
      '150g salmon fillet',
      '2 sdm saus teriyaki (halal)',
      'Brokoli rebus',
      'Sedikit wijen sangrai'
    ],
    instructions: [
      'Marinat salmon dengan saus teriyaki selama 15 menit.',
      'Panggang salmon di teflon dengan sedikit minyak.',
      'Sajikan dengan brokoli rebus dan taburan wijen.'
    ],
  ),
  Recipe(
    id: '5',
    title: 'Tempe Orek Basah',
    description: 'Protein nabati lezat dan murah meriah.',
    calories: 250,
    protein: 15,
    fat: 10,
    carbs: 20,
    imageUrl: 'https://images.unsplash.com/photo-1626500746934-2e6840702672?auto=format&fit=crop&w=800&q=80', // Placeholder
    tags: 'Vegan, Local',
    dietGoals: ['fatLoss', 'maintenance'],
    mealTypes: ['lunch', 'dinner'],
    isHalal: true,
    isVegetarian: true,
    isVegan: true,
    ingredients: [
      '1 papan tempe, potong dadu',
      '3 siung bawang merah & 2 bawang putih',
      'Kecap manis secukupnya',
      'Cabai merah sesuai selera'
    ],
    instructions: [
      'Goreng tempe setengah matang.',
      'Tumis bawang dan cabai hingga harum.',
      'Masukkan tempe dan kecap, beri sedikit air.',
      'Masak hingga air menyusut.'
    ],
  ),
];
