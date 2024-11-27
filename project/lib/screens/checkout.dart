import 'package:flutter/material.dart';
import 'package:project/screens/dashboard.dart';
import 'package:project/screens/payment.dart';
import 'package:project/screens/toShip.dart';
// import 'package:project/utils/handleRequest.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'dart:async';

import 'package:project/utils/handleRequest.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:webview_flutter/webview_flutter.dart';

class CheckoutScreen extends StatefulWidget {
  final dynamic user;
  final List<Map<String, dynamic>> products;
  const CheckoutScreen(this.user, this.products, {super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'Cash on Delivery';
  double shipping = 5.0;
  double totalPayment = 0;
  double discount = 10.0;
  double merchandiseTotal = 0;

  @override
  Widget build(BuildContext context) {
    for (var product in widget.products) {
      merchandiseTotal += product['price'] * product['numberOfProduct'];
    }
    totalPayment = merchandiseTotal + shipping - discount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.pink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.user['firstName']} ${widget.user['lastName']} (${widget.user['phoneNumber'] != '' ? widget.user['phoneNumber'] : 'NOT SET'})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.user['location'] != '' ? widget.user['location'] : 'NOT SET'}',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const Divider(thickness: 1, color: Colors.black26),
            const SizedBox(height: 20),
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              items: ['Cash on Delivery', 'Gcash']
                  .map((method) => DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.products.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                  leading: Image.network(
                    widget.products[index]['productImage'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    widget.products[index]['name'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Quantity: ${widget.products[index]['numberOfProduct']} - ₱${widget.products[index]['price']} each',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  trailing: Text(
                    '₱${(widget.products[index]['price'] * widget.products[index]['numberOfProduct']).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
            const Divider(thickness: 1, color: Colors.black26),
            const SizedBox(height: 20),
            const Text(
              'Payment Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildPaymentRow('Payment Method', _selectedPaymentMethod),
            _buildPaymentRow('Merchandise Total', '₱$merchandiseTotal'),
            _buildPaymentRow('Shipping', '₱$shipping'),
            _buildPaymentRow('Discount', '-₱$discount'),
            const Divider(thickness: 1, color: Colors.black26),
            _buildPaymentRow('Total Payment', '₱$totalPayment', isTotal: true),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _orderCheckout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Place Order',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _orderCheckout() async {
    if (_selectedPaymentMethod == 'Gcash') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (builder) => PaymentScreen(widget.user, widget.products, shipping, discount, merchandiseTotal,
                  amount: totalPayment)));
      return;
    }

    bool stockAvailable = widget.products.every((product) => product['stock'] >= product['numberOfProduct']);
    if (!stockAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('One or more products are out of stock. Please adjust your order.')),
      );
      return;
    }

    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response = await requestHandler.handleRequest(context, 'orders/bulkOrder', body: {
        'products': widget.products,
        'userId': widget.user['id'],
        'shoppingFee': shipping,
        'discountFee': discount,
        'subTotalFee': merchandiseTotal,
        'isPaid': false
      });

      if (response['success'] == true) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen(user: widget.user, selectInitialIndex: 3)),
            (Route<dynamic> route) => false,
          );
          Navigator.push(context,
              MaterialPageRoute(builder: (builder) => ToShipScreen(widget.user, toShip: true, textAbove: "To Ship")));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Successfully placed order'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Placing order error'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }
}
