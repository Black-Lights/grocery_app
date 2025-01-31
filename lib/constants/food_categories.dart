class FoodCategory {
  final String name;
  final String iconPath;

  const FoodCategory({
    required this.name,
    required this.iconPath,
  });
}

const List<FoodCategory> foodCategories = [
  FoodCategory(
    name: 'Fruits',
    iconPath: 'assets/images/category_icons/fruits.png',
  ),
  FoodCategory(
    name: 'Vegetables',
    iconPath: 'assets/images/category_icons/vegetables.png',
  ),
  FoodCategory(
    name: 'Dairy',
    iconPath: 'assets/images/category_icons/dairy.png',
  ),
  FoodCategory(
    name: 'Meat',
    iconPath: 'assets/images/category_icons/meat.png',
  ),
  FoodCategory(
    name: 'Poultry',
    iconPath: 'assets/images/category_icons/Poultry.png',
  ),
  FoodCategory(
    name: 'Seafood',
    iconPath: 'assets/images/category_icons/seafood.png',
  ),
  FoodCategory(
    name: 'Grains',
    iconPath: 'assets/images/category_icons/Grains.png',
  ),
  FoodCategory(
    name: 'Bread',
    iconPath: 'assets/images/category_icons/Bread.png',
  ),
  FoodCategory(
    name: 'Pasta',
    iconPath: 'assets/images/category_icons/Pasta.png',
  ),
  FoodCategory(
    name: 'Snacks',
    iconPath: 'assets/images/category_icons/Snacks.png',
  ),
  FoodCategory(
    name: 'Beverages',
    iconPath: 'assets/images/category_icons/Beverages.png',
  ),
  FoodCategory(
    name: 'Condiments',
    iconPath: 'assets/images/category_icons/Condiments.png',
  ),
  FoodCategory(
    name: 'Sauces',
    iconPath: 'assets/images/category_icons/Sauces.png',
  ),
  FoodCategory(
    name: 'Spices',
    iconPath: 'assets/images/category_icons/Spices.png',
  ),
  FoodCategory(
    name: 'Herbs',
    iconPath: 'assets/images/category_icons/Herbs.png',
  ),
  FoodCategory(
    name: 'Baking Supplies',
    iconPath: 'assets/images/category_icons/Baking Supplies.png',
  ),
  FoodCategory(
    name: 'Canned Goods',
    iconPath: 'assets/images/category_icons/Canned_Goods.png',
  ),
  FoodCategory(
    name: 'Frozen Foods',
    iconPath: 'assets/images/category_icons/Frozen_Foods.png',
  ),
  FoodCategory(
    name: 'Ready-to-eat Meals',
    iconPath: 'assets/images/category_icons/Ready_to_eat_Meals.png',
  ),
  FoodCategory(
    name: 'Breakfast Foods',
    iconPath: 'assets/images/category_icons/Breakfast_Foods.png',
  ),
  FoodCategory(
    name: 'Desserts',
    iconPath: 'assets/images/category_icons/Desserts.png',
  ),
  FoodCategory(
    name: 'Nuts and Seeds',
    iconPath: 'assets/images/category_icons/Nuts_and_Seeds.png',
  ),
  FoodCategory(
    name: 'Oils and Vinegars',
    iconPath: 'assets/images/category_icons/Oils_and_Vinegars.png',
  ),
  FoodCategory(
    name: 'Processed Foods',
    iconPath: 'assets/images/category_icons/Processed_Foods.png',
  ),
  FoodCategory(
    name: 'Baby Food',
    iconPath: 'assets/images/category_icons/Baby_Food.png',
  ),
  FoodCategory(
    name: 'Pet Food',
    iconPath: 'assets/images/category_icons/Pet_Food.png',
  ),
  FoodCategory(
    name: 'Health Foods',
    iconPath: 'assets/images/category_icons/Health_Foods.png',
  ),
  FoodCategory(
    name: 'Organic Products',
    iconPath: 'assets/images/category_icons/Organic_Products.png',
  ),
  FoodCategory(
    name: 'Gluten-free Products',
    iconPath: 'assets/images/category_icons/Gluten_free_Products.png',
  ),
  FoodCategory(
    name: 'International Foods',
    iconPath: 'assets/images/category_icons/International_Foods.png',
  ),
  FoodCategory(
    name: 'Others',
    iconPath: 'assets/images/category_icons/others.png',
  ),
];

// Helper methods
List<String> get foodCategoryNames => 
    foodCategories.map((cat) => cat.name).toList();

String getCategoryIcon(String categoryName) {
  final category = foodCategories.firstWhere(
    (cat) => cat.name.toLowerCase() == categoryName.toLowerCase(),
    orElse: () => foodCategories.last,
  );
  return category.iconPath;
}
