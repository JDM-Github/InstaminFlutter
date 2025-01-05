import 'package:flutter/material.dart';
import 'package:project/screens/payment.dart';

class EWalletSelectionScreen extends StatelessWidget {
  final dynamic user;
  final dynamic products;
  final double shipping;
  final double discount;
  final double merchandiseTotal;
  final double totalPayment;

  const EWalletSelectionScreen({
    super.key,
    required this.user,
    required this.products,
    required this.shipping,
    required this.discount,
    required this.merchandiseTotal,
    required this.totalPayment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select E-wallet"),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildEwalletTile(
            context,
            walletName: "GCash",
            walletType: 'gcash',
            walletIcon: Icons.account_balance_wallet,
            offerText: "No offer in this service",
          ),
          _buildEwalletTile(
            context,
            walletName: "PayMaya",
            walletType: 'paymaya',
            walletIcon: Icons.credit_card,
            offerText: "No offer in this service",
          ),
          _buildEwalletTile(
            context,
            walletName: "ShopeePay",
            walletType: 'shopeepay',
            walletIcon: Icons.local_mall,
            offerText: "No offer in this service",
          ),
          _buildEwalletTile(
            context,
            walletName: "GrabPay",
            walletType: 'grabpay',
            walletIcon: Icons.directions_car,
            offerText: "No offer in this service",
          ),
          _buildEwalletTile(
            context,
            walletName: "GWallet",
            walletType: 'gwallet',
            walletIcon: Icons.wallet_travel,
            offerText: "No offer in this service",
          ),
        ],
      ),
    );
  }

  Widget _buildEwalletTile(
    BuildContext context, {
    required String walletName,
    required String walletType,
    required IconData walletIcon,
    required String offerText,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) => PaymentScreen(
                user,
                products,
                shipping,
                discount,
                merchandiseTotal,
                amount: totalPayment,
                walletType: walletType,
              ),
            ),
          );
        },
        leading: Icon(walletIcon, color: Colors.pink, size: 30),
        title: Text(
          walletName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.pink,
          ),
        ),
        subtitle: Text(
          offerText,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.pink, size: 20),
      ),
    );
  }
}
