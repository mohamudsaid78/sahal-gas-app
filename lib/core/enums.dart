enum UserRole {
  admin,
  driver,
  customer;

  String get label {
    return switch (this) {
      UserRole.admin => 'Admin',
      UserRole.driver => 'Driver',
      UserRole.customer => 'Customer',
    };
  }

  String get databaseValue => name;

  static UserRole fromValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();
    return switch (normalized) {
      'admin' => UserRole.admin,
      'driver' => UserRole.driver,
      _ => UserRole.customer,
    };
  }
}

enum OrderStatus {
  placed,
  confirmed,
  onTheWay,
  delivered,
  cancelled;

  String get label {
    return switch (this) {
      OrderStatus.placed => 'Placed',
      OrderStatus.confirmed => 'Confirmed',
      OrderStatus.onTheWay => 'On the way',
      OrderStatus.delivered => 'Delivered',
      OrderStatus.cancelled => 'Cancelled',
    };
  }

  String get databaseValue {
    return switch (this) {
      OrderStatus.onTheWay => 'on_the_way',
      _ => name,
    };
  }

  static OrderStatus fromValue(Object? value) {
    final normalized = value
        ?.toString()
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    return switch (normalized) {
      'confirmed' => OrderStatus.confirmed,
      'on_the_way' || 'ontheway' => OrderStatus.onTheWay,
      'delivered' => OrderStatus.delivered,
      'cancelled' || 'canceled' => OrderStatus.cancelled,
      _ => OrderStatus.placed,
    };
  }
}
