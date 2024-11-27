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

  const PaymentScreen(this.user, this.products, this.shipping, this.discount, this.merchandiseTotal,
      {super.key, required this.amount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.100.151:8888/.netlify/functions/api/create-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': widget.amount, 'description': 'Order Payment'}),
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
                  _handleSuccess();
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
                  _handleSuccess();
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

  void _handleSuccess() async {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment Successful!')),
    );

    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response = await requestHandler.handleRequest(context, 'orders/bulkOrder', body: {
        'products': widget.products,
        'userId': widget.user['id'],
        'shoppingFee': widget.shipping,
        'discountFee': widget.discount,
        'subTotalFee': widget.merchandiseTotal,
        'isPaid': true
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

  void _handleFailure() {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment Failed!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body:
          _isLoading ? const Center(child: CircularProgressIndicator()) : WebViewWidget(controller: _webViewController),
    );
  }
}
