import 'package:flutter/material.dart';

class PriceModel extends ChangeNotifier {
  bool _selfPU = false;
  bool _delivery = false;
  int _price = 0;
  List _cart = [];

  bool get selfPU => _selfPU;
  bool get delivery => _delivery;

  void discount(index, user, discount) {
    _cart[index]['discount'] = int.parse(discount);
    user.updateData({'current_cart': _cart});
    notifyListeners();
  }

  void convert() {
    for (int i = 0; i < _cart.length; i++) {
      _cart[i] = Map.from(_cart[i]);
      _cart[i]['item'] = Map.from(_cart[i]['item']);
    }
  }

  void calcPrice() {
    _price = 0;
    for (int i = 0; i < _cart.length; i++) {
      _price += _cart[i]['quantity'] * _cart[i]['item']['price'];
    }
  }

  set cart(item) => _cart = item;
  List get cart => _cart;

  int getQuantity(int index) {
    return _cart[index]['quantity'];
  }

  void addQuantity(index, user) {
    _cart[index]['quantity'] += 1;
    _price += _cart[index]['item']['price'];
    user.updateData({'current_cart': _cart});
    notifyListeners();
  }

  void reduceQuantity(index, user) {
    _cart[index]['quantity'] -= 1;
    _price -= _cart[index]['item']['price'];
    if (_cart[index]['quantity'] == 0) {
      _cart.removeAt(index);
    }
    user.updateData({'current_cart': _cart});
    notifyListeners();
  }

  int getPrice(index) {
    return _cart[index]['item']['price'];
  }

  void puPressed() {
    _selfPU = true;
    if (_delivery) {
      _delivery = false;
    }
    notifyListeners();
  }

  void deliveryPressed() {
    _delivery = true;
    if (_selfPU) {
      _selfPU = false;
    }
    notifyListeners();
  }

  int get price => _price;
  set price(amount) => _price = amount;
  void add(int amount) {
    _price += amount;
    notifyListeners();
  }

  void subtract(int amount) {
    _price -= amount;
    notifyListeners();
  }

  void printSummary() {
    print(
        "Cart items with quantity : $_cart\nSelf Pick Up : $_selfPU\nDelivery : $_delivery\nTotal cost : $_price");
  }
}
