import 'package:flutter/material.dart';
import 'package:project/utils/handleRequest.dart';

class NotificationDashboard extends StatefulWidget {
  final dynamic user;
  const NotificationDashboard(this.user, {super.key});

  @override
  State<NotificationDashboard> createState() => _NotificationDashboardState();
}

class _NotificationDashboardState extends State<NotificationDashboard> {
  List<dynamic> _notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response =
          await requestHandler.handleRequest(context, 'user/getAllNotification', body: {'id': widget.user['id']});
      setState(() {
        isLoading = false;
      });
      if (response['success'] == true) {
        setAllNotification(response['notification'] ?? {});
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Loading notification error'),
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

  void setAllNotification(List<dynamic> notification) {
    setState(() {
      _notifications = notification;
    });
  }

  void _showNotificationModal(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(description),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _markAsRead(int index) async {
    setState(() {
      _notifications[index]['isRead'] = true;
    });

    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response = await requestHandler.handleRequest(context, 'user/updateNotification',
          body: {'notificationId': _notifications[index]['id']}, willLoadingShow: false);

      if (response['success'] == true) {
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Error updating read notification'),
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
    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        final isRead = notification['isRead'];
        return _notifications.isEmpty
            ? const Center(
                child: Text(
                  'Your notification is empty',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListTile(
                title: Text(
                  notification['title'],
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    color: isRead ? Colors.grey : Colors.black,
                  ),
                ),
                subtitle: Text(
                  notification['description'],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isRead ? Colors.grey : Colors.black87,
                  ),
                ),
                trailing: Icon(
                  isRead ? Icons.check_circle_outline : Icons.circle_notifications,
                  color: isRead ? Colors.grey : Colors.pink,
                ),
                onTap: () {
                  _markAsRead(index);
                  _showNotificationModal(
                    context,
                    notification['title'],
                    notification['description'],
                  );
                },
              );
      },
    );
  }
}
