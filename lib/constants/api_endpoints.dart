class ApiEndpoints {
  static const String baseUrl = 'http://office.quicserve.test/api/';
  static const Duration timeout = Duration(seconds: 30);

  // Auth endpoints
  static const String login = '/login';
  static const String stafflogin = '/staff/login';
  static const String logout = '/staff/logout';

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
}
