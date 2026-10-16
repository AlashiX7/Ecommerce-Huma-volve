class ApiEndpoints {
  const ApiEndpoints._();

  static const login = 'auth/login';
  static const users = 'users/';
  static const categories = 'categories';
  static const products = 'products';

  static String productDetails(int productId) => 'products/$productId';

  static String categoryProducts(int categoryId) =>
      'categories/$categoryId/products';
}
