import 'package:flutter/material.dart';
import 'package:project/screens/dashboard.dart';
import 'package:project/screens/toShip.dart';
import 'package:project/utils/handleRequest.dart';
import 'package:webview_flutter/webview_flutter.dart';


class PayScreen extends StatefulWidget {
  final dynamic user;
  final String redirectUrl;
  final String id;

  const PayScreen(
    this.redirectUrl,
    this.user, this.id, {super.key}
  );

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializePayment(widget.redirectUrl));
  }

  Future<void> _initializePayment(String redirectUrl) async {
    // if (widget.user.location == "" || widget.user.location == null)
    // {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('User has no location. Cannot placed the order.'),
    //     ),
    //   );
    //   Navigator.pop(context);
    //   return;
    // }
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              print("Loading Progress: $progress%");
            },
            onPageStarted: (String url) {
              if (url.contains('payment-success')) {
                paymentSuccess(widget.id);
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
                paymentSuccess(widget.id);
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
  }

  void paymentSuccess(String id) async {
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
      Map<String, dynamic> response = await requestHandler.handleRequest(context, 'orders/paidOrder',
          body: {'id': id, 'email': email, 'notificationMessage': notificationMessage});

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
