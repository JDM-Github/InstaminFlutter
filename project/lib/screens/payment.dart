import 'package:flutter/material.dart';
import 'package:project/screens/dashboard.dart';
import 'package:project/screens/toShip.dart';
import 'package:project/utils/handleRequest.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final dynamic user;
  final dynamic products;
  final double shipping;
  final double discount;
  final double merchandiseTotal;
  final String? walletType;

  const PaymentScreen(
    this.user,
    this.products,
    this.shipping,
    this.discount,
    this.merchandiseTotal, {
    super.key,
    required this.amount,
    this.walletType,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializePayment());
  }

  Future<void> _initializePayment() async {
    try {
      dynamic order = await _handleSuccess();
      if (order['success'] == false)
      {
        _handleFailure();
        return;
      }
      final response = await http.post(
        Uri.parse('https://instantmine.netlify.app/.netlify/functions/api/create-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': widget.amount, 'description': 'Order Payment', 'walletType': widget.walletType,
          'products': widget.products, 'users': widget.user, 'order': order['orderBatch']
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String redirectUrl = data['redirectUrl'];

        _webViewController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                print("Loading Progress: $progress%");
              },
              onPageStarted: (String url) {
                if (url.contains('payment-success')) {
                  paymentSuccess(order['orderBatch']['id']);
                } else if (url.contains('payment-failed')) {
                  _handleFailure();
                }
              },
              onPageFinished: (String url) {
                setState(() {
                  _isLoading = false;
                });
              },
              onHttpError: (HttpResponseError error) {
                print("HTTP Error: $error");
              },
              onWebResourceError: (WebResourceError error) {
                print("Web Resource Error: $error");
              },
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.startsWith('https://yourdomain.com/payment-success')) {
                  paymentSuccess(order['orderBatch']['id']);
                  return NavigationDecision.prevent;
                }
                if (request.url.startsWith('https://yourdomain.com/payment-failed')) {
                  _handleFailure();
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(redirectUrl));
      } else {
        throw 'Failed to initiate payment: ${response.body}';
      }
    } catch (e) {
      print('Error initiating payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void paymentSuccess(String id) async
  {
    RequestHandler requestHandler = RequestHandler();

    try {
      String email = widget.user['email'];
      String notificationMessage = """
      Hello ${widget.user['username']},

      Thank you for your recent order with InstaMine! We are pleased to inform you that your order has been successfully placed and is now being processed.

      You will be notified once your order is ready to be shipped. If you have any questions or need further assistance, feel free to contact our support team.

      Thank you for choosing InstaMine. We hope you enjoy your purchase!

      Best regards, 
      The InstaMine Business Team
      """;
      Map<String, dynamic> response = await requestHandler.handleRequest(context, 'orders/paidOrder', body: {
        'id': id,
        'email': email,
        'notificationMessage': notificationMessage
      });

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Successfully purchased the order'),
            ),
          );
          Navigator.pushAndRemoveUntil(
              context,
            MaterialPageRoute(builder: (context) => DashboardScreen(user: widget.user, selectInitialIndex: 3)),
            (Route<dynamic> route) => false,
          );
          Navigator.push(context,
            MaterialPageRoute(builder: (builder) => ToShipScreen(widget.user, toShip: true, textAbove: "To Ship")));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Purchasing order error'),
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

  dynamic _handleSuccess() async {
    // if (widget.user.location == "" || widget.user.location == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('User has no location. Cannot placed the order.'),
    //     ),
    //   );
    //   Navigator.pop(context);
    //   return;
    // }

    RequestHandler requestHandler = RequestHandler();
    try {
      String email = widget.user['email'];
      String notificationMessage = """
      Hello ${widget.user['username']},

      Thank you for your recent order with InstaMine! We are pleased to inform you that your order has been successfully placed and is now being processed.

      Order Summary:
      - Items: ${widget.products.length} product(s)
      - Shipping: ₱${widget.shipping}
      - Discount: -₱${widget.discount}
      - Total: ₱${widget.merchandiseTotal}

      You will be notified once your order is ready to be shipped. If you have any questions or need further assistance, feel free to contact our support team.

      Thank you for choosing InstaMine. We hope you enjoy your purchase!

      Best regards, 
      The InstaMine Business Team
      """;
      Map<String, dynamic> response = await requestHandler.handleRequest(context, 'orders/bulkOrder', body: {
        'products': widget.products,
        'userId': widget.user['id'],
        'shoppingFee': widget.shipping,
        'discountFee': widget.discount,
        'subTotalFee': widget.merchandiseTotal,
        'isPaid': false,
        'email': email,
        'notificationMessage': notificationMessage
      });

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Successfully placed order'),
            ),
          );
          return response;
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Placing order error'),
            ),
          );
          return response;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
      return {'success': false};
    }
  }

  void _handleFailure() {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment Failed!')),
    );
    Navigator.pop(context);
  }

  // Future<void> sendEmail() async {
  //   if (widget.user['email'] == null || widget.user['email'].isEmpty) return;

  //   RequestHandler requestHandler = RequestHandler();
  //   try {
  //     String email = widget.user['email'];
  //     String notificationMessage = """
  //     Hello ${widget.user['username']},

  //     Thank you for your recent purchase with InstaMine! We are pleased to inform you that your order has been successfully placed and is now being processed.

  //     Order Summary:
  //     - Items: ${widget.products.length} product(s)
  //     - Shipping: ₱${widget.shipping}
  //     - Discount: -₱${widget.discount}
  //     - Total: ₱${widget.merchandiseTotal}

  //     You will be notified once your order is ready to be shipped. If you have any questions or need further assistance, feel free to contact our support team.

  //     Thank you for choosing InstaMine. We hope you enjoy your purchase!

  //     Best regards,
  //     The InstaMine Business Team
  //     """;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body:
          _isLoading ? const Center(child: CircularProgressIndicator()) : WebViewWidget(controller: _webViewController),
    );
  }
}
