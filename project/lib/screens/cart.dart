import 'package:flutter/material.dart';
import 'package:project/screens/checkout.dart';
import 'package:project/utils/handleRequest.dart';

class CartScreen extends StatefulWidget {
  final dynamic user;
  const CartScreen(this.user, {super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response =
          await requestHandler.handleRequest(context, 'cart/getAllCartById?userId=${widget.user['id']}', type: "get");

      if (response['success'] == true) {
        response['cart'].forEach((product) {
          setState(() {
            print(product);
            _cartItems.add({
              'id': product['id'],
              'productId': product['productId'],
              'name': product['Product']['name'],
              'price': double.parse(product['Product']['price']),
              'quantity': int.parse(product['numberOfCart']),
              'number_of_stock': int.parse(product['Product']['number_of_stock']),
              'image': product['Product']['product_image'],
              'isSelected': false,
            });
          });
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Fetching cart error'),
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

  double get _totalPrice {
    return _cartItems.fold(0, (total, item) {
      if (item['isSelected']) {
        return total + (item['price'] * item['quantity']);
      }
      return total;
    });
  }

  void _removeItem(int index) async {
    List selectedItemIds = [_cartItems[index]['id']];
    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response = await requestHandler.handleRequest(
        context,
        'cart/updateCart',
        body: {'cartIds': selectedItemIds},
        willLoadingShow: false,
      );

      if (response['success'] == true) {
        setState(() {
          _cartItems.removeAt(index);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Error deleting cart')),
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

  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }

  void _updateQuantity(int index, int change) async {
    setState(() {
      _cartItems[index]['quantity'] =
          (_cartItems[index]['quantity'] + change).clamp(1, _cartItems[index]['number_of_stock']);
    });

    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response = await requestHandler.handleRequest(
        context,
        'cart/updateCartQuantity',
        body: {'cartId': _cartItems[index]['id'], 'quantity': _cartItems[index]['quantity']},
        willLoadingShow: false,
      );

      if (response['success'] == true) {
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Error updating cart')),
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

  void _toggleSelection(int index) {
    setState(() {
      _cartItems[index]['isSelected'] = !_cartItems[index]['isSelected'];
    });
  }

  void _selectAllItems({value = true}) {
    setState(() {
      for (var item in _cartItems) {
        item['isSelected'] = value!;
      }
    });
  }

  void _removeSelectedItems() async {
    List selectedItemIds = _cartItems.where((item) => item['isSelected'] == true).map((item) => item['id']).toList();
    setState(() {
      _cartItems.removeWhere((item) => item['isSelected']);
    });

    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response = await requestHandler.handleRequest(
        context,
        'cart/updateCart',
        body: {'cartIds': selectedItemIds},
        willLoadingShow: false,
      );
      if (response['success'] == true) {
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Error deleting cart'),
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
        title: const Text('Your Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.deselect),
            onPressed: () => {_selectAllItems(value: false)},
          ),
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: _selectAllItems,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearCart,
          ),
        ],
        backgroundColor: Colors.pink,
      ),
      body: _cartItems.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.5), // Divider line
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: item['isSelected'],
                        onChanged: (bool? value) {
                          _toggleSelection(index);
                        },
                        activeColor: Colors.pink,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item['image'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '₱${item['price'].toString()}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.pink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => _updateQuantity(index, -1),
                                  icon: const Icon(Icons.remove, size: 18),
                                  color: Colors.grey[700],
                                  padding: const EdgeInsets.all(0),
                                  constraints: const BoxConstraints(),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item['quantity'].toString(),
                                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _updateQuantity(index, 1),
                                  icon: const Icon(Icons.add, size: 18),
                                  color: Colors.grey[700],
                                  padding: const EdgeInsets.all(0),
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeItem(index),
                        tooltip: 'Remove item',
                        iconSize: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: ₱${_totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _removeSelectedItems,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'Remove Selected',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    List<Map<String, dynamic>> checkoutOrder =
                        _cartItems.where((item) => item['isSelected']).map((item) {
                      return {
                        'name': item['name'],
                        'price': item['price'],
                        'numberOfProduct': item['quantity'],
                        'productImage': item['image'],
                        'productId': item['productId'],
                        'stock': item['number_of_stock'],
                        'isRated': false,
                        'rating': 0,
                        'note': ""
                      };
                    }).toList();
                    if (checkoutOrder.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a product to checkout.'),
                        ),
                      );
                    } else {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (builder) => CheckoutScreen(widget.user, checkoutOrder)));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'Checkout',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
