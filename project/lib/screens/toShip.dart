import 'dart:math';

import 'package:flutter/material.dart';
import 'package:project/screens/pay.dart';
import 'package:project/utils/handleRequest.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

String generatePin() {
  final random = Random();
  return (random.nextInt(900000) + 100000).toString();
}

class ToShipScreen extends StatefulWidget {
  final bool toShip;
  final bool toReceive;
  final bool isComplete;
  final bool toProcess;
  final String textAbove;
  final dynamic user;

  const ToShipScreen(
    this.user, {
    super.key,
    this.toShip = false,
    this.toReceive = false,
    this.isComplete = false,
    this.toProcess = false,
    required this.textAbove,
  });

  @override
  State<ToShipScreen> createState() => _ToShipScreen();
}

class _ToShipScreen extends State<ToShipScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;
  String? _confirmationPin;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response = await requestHandler.handleRequest(context, 'orders/get-batch-orders', body: {
        'userId': widget.user['id'],
        'toShip': widget.toShip,
        'toReceive': widget.toReceive,
        'isComplete': widget.isComplete,
        'toProcess': widget.toProcess,
      });
      setState(() {
        isLoading = false;
      });
      if (response['success'] == true) {
        setAllProducts(response['orders'] ?? []);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Loading all orders error'),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  void setAllProducts(List<dynamic> orders) {
    setState(() {
      this.orders = orders;
    });
  }

  void _viewOrderDetails(BuildContext context, Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(
            user: widget.user,
            canCancel: widget.toShip,
            toReceive: widget.toReceive,
            isComplete: widget.isComplete,
            order: order),
      ),
    );
  }


  Future<void> sendEmail(index) async {
    if (widget.user['email'] == null || widget.user['email'].isEmpty) return;

    String notificationMessage = """
      Hello ${widget.user['username']},

      Thank you for choosing InstaMine! We're processing your recent order and need a quick confirmation to finalize your cancellation request.

      To proceed with the cancellation, please enter the confirmation pin provided below:

      Confirmation Pin: $_confirmationPin

      Please note that this pin is required for us to verify your action and complete the cancellation process.

      If you did not request a cancellation, please disregard this message. If you have any questions or need assistance, feel free to reach out to our support team.

      Thank you for being a valued customer!

      Best regards,
      The InstaMine Team
      """;

    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> body = {
        "notificationMessage": notificationMessage,
        "email": widget.user['email'],
      };

      Map<String, dynamic> response = await requestHandler.handleRequest(context, 'send-notification', body: body);

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Confirmation sent successfully.'),
            ),
          );
        }
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Cancel Order Confirmation'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('To confirm cancellation. Enter the emailed pin.'),
                  TextField(
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Enter Pin'),
                    onChanged: (pin) {
                      if (pin == _confirmationPin) {
                        Navigator.pop(context);
                        _processCancellation(index);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Error sending email.'),
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

  void _cancelOrder(index) async {
    _confirmationPin = generatePin();
    await sendEmail(index);
  }

  void _processCancellation(index) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order Canceled')),
    );
    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response = await requestHandler.handleRequest(context, 'orders/cancelOrder',
          body: {'orderId': orders[index]['orderId'], 'user': widget.user}, willLoadingShow: true);

      if (response['success'] == true) {
        setState(() {
          orders.removeAt(index);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Successfully cancelled order'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Cancelling order error'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(widget.textAbove),
        backgroundColor: Colors.pink,
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text(
                'There is no order.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];

                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  '${order['isPaid'] ? "(PAID) " : ""}Order ID: ${order['orderId']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: order['status'] == 'Expired' ? Colors.red.withAlpha(10) : Colors.orangeAccent.withAlpha(10),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  order['status'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: order['status'] == 'Expired' ? Colors.red : Colors.orangeAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: order['products'].map<Widget>((product) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${product['name']} (x${product['numberOfProduct']})',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '₱${(product['price'] * product['numberOfProduct']).toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₱${order['totalAmount']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          if (order['reference_number'] != null && order['reference_number'] != '')
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Reference Number: ${order['reference_number']}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ),

                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () => _viewOrderDetails(context, order),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                child: const Text(
                                  'View Details',
                                  style: TextStyle(fontSize: 14, color: Colors.white),
                                ),
                              ),
                              if ((widget.toShip && !order['isPaid']) ||
                                  (order['paymentLink'] != "" && !order['isPaid'] && order['status'] == "Pending"))
                                const SizedBox(width: 10),
                              if ((widget.toShip && !order['isPaid']) || (order['paymentLink'] != "" && !order['isPaid'] && order['status'] == "Pending"))
                                ElevatedButton(
                                  onPressed: () =>(widget.toShip && !order['isPaid']) ? _cancelOrder(index) : _processCancellation(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  ),
                                  child: const Text(
                                    'Cancel Order',
                                    style: TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                ),

                              if (widget.toReceive) const SizedBox(width: 10),
                              if (widget.toReceive)
                                ElevatedButton(
                                  onPressed: () {
                                    completeOrder(context, order);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  ),
                                  child: const Text(
                                    'Complete Order',
                                    style: TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                ),
                              if (order['paymentLink'] != "" && !order['isPaid'] && order['status'] == "Pending") const SizedBox(width: 10),
                              if (order['paymentLink'] != "" && !order['isPaid'] && order['status'] == "Pending")
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (builder) => PayScreen(order['paymentLink'], widget.user, order['orderId'])));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    backgroundColor: Colors.blue,
                                  ),
                                  child: const Text(
                                    'Pay Now',
                                    style: TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                ),
                              if (order['status'] == "Expired") const SizedBox(width: 10),
                              if (order['status'] == "Expired")
                                ElevatedButton(
                                  onPressed: () => _processCancellation(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  ),
                                  child: const Text(
                                    'Remove Order',
                                    style: TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Future<void> completeOrder(BuildContext context, order) async {
    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response =
          await requestHandler.handleRequest(context, 'orders/complete-order', body: {'id': order['orderId']});

      if (response['success'] == true) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (builder) => ToShipScreen(widget.user, textAbove: "Completed Order", isComplete: true)));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complete Order')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Rating product error'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
}

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  final dynamic user;
  final bool canCancel;
  final bool toReceive;
  final bool isComplete;

  const OrderDetailScreen(
      {super.key,
      this.user,
      required this.canCancel,
      required this.toReceive,
      required this.isComplete,
      required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${user['firstName']} ${user['lastName']} (${user['phoneNumber'] != '' ? user['phoneNumber'] : 'NOT SET'})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${user['location'] != '' ? user['location'] : 'NOT SET'}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const Divider(color: Colors.grey, thickness: 1),
              const SizedBox(height: 20),
              Text(
                'Order ID: ${order['orderId']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Status: ${order['status']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: order['status'] == 'Expired' ? Colors.red : Colors.orangeAccent,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Order Date: ${order['createdAt']}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Products:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  itemCount: order['products'].length,
                  itemBuilder: (context, index) {
                    final product = order['products'][index];
                    final bool isRated = product['isRated'] ?? false;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Image.network(
                                  product['productImage'] ?? 'https://via.placeholder.com/150',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '₱${(product['price'] * product['numberOfProduct']).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.pink,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'x${product['numberOfProduct']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (!isRated && order['status'] == "Completed")
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showRatingDialog(context, index, product, user['id']);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  ),
                                  child: const Text(
                                    'Rate',
                                    style: TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            if (isRated && order['status'] == "Completed")
                              Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Rated: ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(
                                        product['rating'].round() ?? 0,
                                        (starIndex) => const Icon(Icons.star, size: 16, color: Colors.amber),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        _showNoteDialog(context, product['note']);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      ),
                                      child: const Text(
                                        'View Note',
                                        style: TextStyle(fontSize: 14, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // const Divider(color: Colors.grey, thickness: 1),
              // const SizedBox(height: 20),
              // const Text(
              //   'Tracking Information:',
              //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 10),
              // (order['allTrack'].length == 0
              //     ? const Center(child: Text("No track record."))
              //     : ListView.builder(
              //         shrinkWrap: true,
              //         physics: const NeverScrollableScrollPhysics(),
              //         itemCount: order['allTrack'].length,
              //         itemBuilder: (context, index) {
              //           final track = order['allTrack'][index];
              //           return Row(
              //             children: [
              //               const Icon(Icons.location_on, color: Colors.blue),
              //               const SizedBox(width: 10),
              //               Expanded(
              //                 child: Text(
              //                   track,
              //                   style: const TextStyle(fontSize: 14, color: Colors.black87),
              //                 ),
              //               ),
              //             ],
              //           );
              //         },
              //       )),
              const SizedBox(height: 20),
              const Divider(color: Colors.grey, thickness: 1),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '₱${order['subTotalFee']}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Discount:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '-₱${order['discountFee']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Shipping Fee:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '₱${order['shoppingFee']}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₱${order['totalAmount']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (canCancel && !order['isPaid']) const SizedBox(height: 10),
              if (canCancel && !order['isPaid'])
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order Canceled')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text(
                    'Cancel Order',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoteDialog(BuildContext context, String? note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('User Note'),
        content: Text(note ?? 'No note provided.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> addRating(BuildContext context, index, userId, rating, note) async {
    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response = await requestHandler.handleRequest(context, 'product/rateProduct',
          body: {'userId': userId, 'order': order, 'index': index, 'rating': rating, 'review': note});
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Succesfully rated."),
          ),
        );
        order['products'][index]['rating'] = rating;
        order['products'][index]['note'] = note;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Rating product error'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void _showRatingDialog(BuildContext context, int index, Map<String, dynamic> product, String userId) {
    final TextEditingController noteController = TextEditingController();
    double rating = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Rate ${product['name']}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rate the product:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Center(
                  child: RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    maxRating: 5,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (newRating) {
                      rating = newRating;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add a note:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Share your experience...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (rating > 0) {
                  final note = noteController.text;
                  addRating(context, index, userId, rating, note);
                  order['products'][index]['isRated'] = true;
                  Navigator.pop(context);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a rating before submitting.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
