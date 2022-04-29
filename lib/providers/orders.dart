import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cart.dart';

class OrderItem {
  final String id;
  final double amounnt;
  final List<CartItem> products;
  final DateTime datetime;

  OrderItem({
    required this.id,
    required this.amounnt,
    required this.products,
    required this.datetime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  List<OrderItem> get orders {
    return [..._orders];
  }

  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  Future<void> fetchAndSetOrders() async {
    var url = Uri.parse(
        "https://flutter-update-41745-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId.json?auth=$authToken");
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];

    if (response.body == "null") {
      return;
    }
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
        id: orderId,
        amounnt: orderData['amounnt'],
        datetime: DateTime.parse(orderData['datetime']),
        products: (orderData['products'] as List<dynamic>)
            .map((item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price'],
                ))
            .toList(),
      ));
    });

    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    var url = Uri.parse(
        "https://flutter-update-41745-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId.json?auth=$authToken");

    final timestamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'amounnt': total,
        'datetime': timestamp.toIso8601String(),
        'products': cartProducts
            .map((product) => {
                  'id': product.id,
                  'title': product.title,
                  'quantity': product.quantity,
                  'price': product.price,
                })
            .toList(),
      }),
    );

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amounnt: total,
        products: cartProducts,
        datetime: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
