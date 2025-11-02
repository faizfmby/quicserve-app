class ApiEndpoints {
  static const String baseUrl = 'https://quicserve.live/api';
  static const Duration timeout = Duration(seconds: 30);

  // Auth endpoints
  static const String login = '/login';
  static const String logout = '/logout';

  // Tenant routes (with slug)
  static String withCompany(String companySlug, String path) {
    return '/$companySlug$path';
  }

  // Cashier endpoints
  static const String cashierLogin = '/clockIn';
  static const String cashierLogout = '/clockOut';

  // Sales endpoints
  static const String sales = '/sales';

  // Order enpoints
  static const String orders = '/orders';

  // Order Item endpoints
  static const String orderItems = '/order-items';

  // Menu Category endpoints
  static const String menucategory = '/menu-category';

  // Item endpoints
  static const String items = '/items';

  // Payment Method endpoints
  static const String paymentMethod = '/payment-method';

  // Staff endpoints
  static const String staff = '/staff';
}
