import 'package:flutter/material.dart';
import 'package:project/screens/dashboard.dart';
import 'package:project/screens/ewallet.dart';
import 'package:project/screens/payment.dart';
import 'package:project/screens/toShip.dart';
import 'dart:async';
import 'package:project/utils/handleRequest.dart';

class CheckoutScreen extends StatefulWidget {
  final dynamic user;
  final List<Map<String, dynamic>> products;
  const CheckoutScreen(this.user, this.products, {super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'Cash on Delivery';
  double shipping = 0;
  double totalPayment = 0;
  double discount = 0;
  double merchandiseTotal = 0;

  @override
  Widget build(BuildContext context) {
    totalPayment = 0;
    merchandiseTotal = 0;
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
              items: ['Cash on Delivery', 'E-wallet']
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
    // if (widget.user.location == "" || widget.user.location == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('User has no location. Cannot placed the order.'),
    //     ),
    //   );
    //   Navigator.pop(context);
    //   return;
    // }
    if (_selectedPaymentMethod == 'E-wallet') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (builder) => PaymentScreen(
            widget.user,
            widget.products,
            shipping,
            discount,
            merchandiseTotal,
            amount: totalPayment,
            walletType: "",
          ),
        ),
      );
      return;
    }

    bool stockAvailable = widget.products.every((product) {
      var stock = product['stock'];
      var numberOfProduct = product['numberOfProduct'];
      if (stock is! int) stock = int.tryParse(stock.toString()) ?? 0;
      if (numberOfProduct is! int) numberOfProduct = int.tryParse(numberOfProduct.toString()) ?? 0;
      return stock >= numberOfProduct;
    });

    if (!stockAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('One or more products are out of stock. Please adjust your order.')),
      );
      return;
    }

    RequestHandler requestHandler = RequestHandler();
    try {
      String email = widget.user['email'];
      String notificationMessage = """
      Hello ${widget.user['username']},

      Thank you for your recent purchase with InstaMine! We are pleased to inform you that your order has been successfully placed and is now being processed.

      Order Summary:
      - Items: ${widget.products.length} product(s)
      - Shipping: ₱$shipping
      - Discount: -₱$discount
      - Total: ₱$totalPayment

      You will be notified once your order is ready to be shipped. If you have any questions or need further assistance, feel free to contact our support team.

      Thank you for choosing InstaMine. We hope you enjoy your purchase!

      Best regards, 
      The InstaMine Business Team
      """;

      Map<String, dynamic> response = await requestHandler.handleRequest(context, 'orders/bulkOrder', body: {
        'products': widget.products,
        'userId': widget.user['id'],
        'shoppingFee': shipping,
        'discountFee': discount,
        'subTotalFee': merchandiseTotal,
        'isPaid': false,
        'email': email,
        'toShip': true,
        'notificationMessage': notificationMessage
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

  // Future<void> sendEmail() async {
  //   if (widget.user['email'] == null || widget.user['email'].isEmpty) return;

  //   RequestHandler requestHandler = RequestHandler();
  //   try {

  //     Map<String, dynamic> body = {
  //       "notificationMessage": notificationMessage,
  //       "email": email,
  //     };

  //     Map<String, dynamic> response = await requestHandler.handleRequest(context, 'send-notification', body: body);

  //     if (response['success'] == true) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(response['message'] ?? 'Email sent successfully.'),
  //           ),
  //         );
  //       }
  //     } else {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(response['message'] ?? 'Error sending email.'),
  //           ),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('An error occurred: $e')),
  //       );
  //     }
  //   }
  // }
}
