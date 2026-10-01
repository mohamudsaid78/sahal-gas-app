import 'package:flutter/foundation.dart';

import '../core/enums.dart';
import '../models/cart_line.dart';
import '../models/gas_cylinder.dart';
import '../models/gas_user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/cylinder_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/schema_repository.dart';
import '../repositories/user_repository.dart';
import '../services/app_settings.dart';

class AppController extends ChangeNotifier {
  AppController({
    AuthRepository? authRepository,
    SchemaRepository? schemaRepository,
    CylinderRepository? cylinderRepository,
    OrderRepository? orderRepository,
    NotificationRepository? notificationRepository,
    UserRepository? userRepository,
    // When true the app will always start at the login screen
    bool alwaysRequireLogin = true,
  })  : authRepository = authRepository ?? AuthRepository(),
        schemaRepository = schemaRepository ?? SchemaRepository(),
        cylinderRepository = cylinderRepository ?? CylinderRepository(),
        orderRepository = orderRepository ?? OrderRepository(),
        notificationRepository = notificationRepository ?? NotificationRepository(),
        userRepository = userRepository ?? UserRepository(),
        alwaysRequireLogin = alwaysRequireLogin;

  final AuthRepository authRepository;
  final SchemaRepository schemaRepository;
  final CylinderRepository cylinderRepository;
  final OrderRepository orderRepository;
  final NotificationRepository notificationRepository;
  final UserRepository userRepository;

  final bool alwaysRequireLogin;

  GasUser? currentUser;
  bool bootstrapping = true;
  bool busy = false;
  int adminNewOrderCount = 0;
  String? startupMessage;
  String? actionMessage;
  String language = 'English';
  String appearance = 'Light';
  final List<CartLine> cart = [];

  double get cartSubtotal {
    return cart.fold(0, (total, line) => total + line.subtotal);
  }

  double get deliveryFee => cart.isEmpty ? 0 : 2;

  double get cartTotal => cartSubtotal + deliveryFee;

  int get cartQuantity {
    return cart.fold(0, (total, line) => total + line.quantity);
  }

  Future<void> bootstrap() async {
    bootstrapping = true;
    notifyListeners();
    try {
      await schemaRepository.ensureCreated();
    } catch (error) {
      startupMessage = 'Could not prepare database tables: $error';
    }
    try {
      currentUser = await authRepository.restoreSession();
    } catch (error) {
      startupMessage = 'Could not restore saved login: $error';
      currentUser = null;
    }
    // If configured, ignore any restored session and require login each launch
    if (alwaysRequireLogin) {
      currentUser = null;
    }
    language = await AppSettings.language();
    appearance = await AppSettings.appearance();
    bootstrapping = false;
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    language = value;
    await AppSettings.setLanguage(value);
    notifyListeners();
  }

  Future<void> refreshAdminNewOrderCount() async {
    final user = currentUser;
    if (user == null || user.role != UserRole.admin) return;
    adminNewOrderCount = await notificationRepository.fetchUnreadOrderCount(
      user.id,
    );
    notifyListeners();
  }

  Future<void> setAppearance(String value) async {
    appearance = value;
    await AppSettings.setAppearance(value);
    notifyListeners();
  }

  Future<bool> signIn({required String username, required String password}) async {
    return _runAction(() async {
      currentUser = await authRepository.signIn(username: username, password: password);
      cart.clear();
    });
  }

  Future<bool> signUp({
    required String name,
    required String username,
    required String phone,
    required String password,
    required String address,
  }) async {
    return _runAction(() async {
      currentUser = await authRepository.signUp(
        name: name,
        username: username,
        phone: phone,
        password: password,
        address: address,
      );
      cart.clear();
    });
  }

  Future<void> signOut() async {
    await authRepository.signOut();
    currentUser = null;
    cart.clear();
    notifyListeners();
  }

  void addToCart(GasCylinder cylinder, {int quantity = 1}) {
    final index = cart.indexWhere((line) => line.cylinder.id == cylinder.id);
    if (index == -1) {
      cart.add(CartLine(cylinder: cylinder, quantity: quantity));
    } else {
      final existing = cart[index];
      cart[index] = existing.copyWith(quantity: existing.quantity + quantity);
    }
    notifyListeners();
  }

  void updateCartQuantity(String cylinderId, int quantity) {
    if (quantity <= 0) {
      cart.removeWhere((line) => line.cylinder.id == cylinderId);
    } else {
      final index = cart.indexWhere((line) => line.cylinder.id == cylinderId);
      if (index != -1) {
        cart[index] = cart[index].copyWith(quantity: quantity);
      }
    }
    notifyListeners();
  }

  void setCurrentUser(GasUser user) {
    currentUser = user;
    notifyListeners();
  }

  Future<bool> placeCartOrder({
    required String deliveryAddress,
    required String paymentMethod,
    required Map<String, dynamic> paymentDetails,
  }) async {
    final user = currentUser;
    if (user == null || cart.isEmpty) return false;
    return _runAction(() async {
      await orderRepository.createOrders(
        customerId: user.id,
        cart: List<CartLine>.from(cart),
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        paymentDetails: paymentDetails,
      );
      cart.clear();
    });
  }

  Future<bool> _runAction(Future<void> Function() action) async {
    busy = true;
    actionMessage = null;
    notifyListeners();
    try {
      await action();
      busy = false;
      notifyListeners();
      return true;
    } catch (error) {
      actionMessage = error.toString().replaceFirst('Exception: ', '');
      busy = false;
      notifyListeners();
      return false;
    }
  }
}
