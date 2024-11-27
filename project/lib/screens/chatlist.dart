import 'package:flutter/material.dart';
import 'package:project/utils/handleRequest.dart';

class ChatDetailScreen extends StatefulWidget {
  final String userId;
  final String partnerId;

  const ChatDetailScreen({super.key, required this.userId, required this.partnerId});

  @override
  State<StatefulWidget> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  List<Map<String, dynamic>> messages = []; // Use dynamic for time fields

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response = await requestHandler.handleRequest(context, 'chats/retrieve-chat',
          body: {'userId': widget.userId, 'partnerId': widget.partnerId});

      if (response['success'] == true) {
        List chatMessages = response['messages'];
        setState(() {
          messages = chatMessages.map((msg) {
            return {
              'sender': msg['sender'] == widget.userId ? 'You' : 'Partner',
              'message': msg['message'] ?? 'No message',
            };
          }).toList();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Loading chats error'),
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

  final TextEditingController _controller = TextEditingController();
  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      RequestHandler requestHandler = RequestHandler();
      try {
        Map<String, dynamic> response = await requestHandler.handleRequest(context, 'chats/message',
            body: {'userId': widget.userId, 'partnerId': widget.partnerId, 'message': _controller.text});

        if (response['success'] == true) {
          setState(() {
            messages.add({
              'sender': 'You',
              'message': _controller.text,
            });
            _controller.clear();
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Sending message error'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Chat with Seller'),
        backgroundColor: Colors.pink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.pink),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: Align(
        alignment: message['sender'] == 'You' ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: message['sender'] == 'You' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: message['sender'] == 'You' ? Colors.pink : Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                message['message']!,
                style: TextStyle(color: message['sender'] == 'You' ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatListScreen extends StatefulWidget {
  final dynamic user;
  const ChatListScreen(this.user, {super.key});

  @override
  State<StatefulWidget> createState() => _ChatListScreen();
}

class _ChatListScreen extends State<ChatListScreen> {
  List<dynamic> chatData = [];

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response =
          await requestHandler.handleRequest(context, 'chats/get-chats', body: {'userId': widget.user['id']});

      if (response['success'] == true) {
        List<dynamic> chats = response['chats'] ?? [];
        setState(() {
          chatData = chats.map((chat) {
            final lastMessage = chat['lastMessage'] is Map ? chat['lastMessage'] as Map : {'message': ''};
            final String formattedTimestamp = _formatTimestamp(chat['createdAt']);
            return {
              'name': chat['username'] ?? 'Unknown',
              'message': lastMessage['message']?.toString() ?? 'No messages yet',
              'chatMessageId': chat['chatMessageId'] ?? '',
              'timestamp': formattedTimestamp,
              'image': chat['profileImage'] ?? 'https://via.placeholder.com/150',
            };
          }).toList();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Loading chats error'),
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
        title: const Text('Chat List'),
        backgroundColor: Colors.pink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: chatData.length,
        itemBuilder: (context, index) {
          return _buildChatItem(context, chatData[index]);
        },
      ),
    );
  }

  String _formatTimestamp(String createdAt) {
    DateTime now = DateTime.now();
    DateTime chatDate = DateTime.parse(createdAt); // Parse the timestamp
    Duration diff = now.difference(chatDate);

    if (diff.inMinutes < 2) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }
  }

  Widget _buildChatItem(BuildContext context, Map<String, dynamic> chat) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(chat['image']!),
      ),
      title: Text(
        chat['name']!,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        chat['message']!,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.black87),
      ),
      trailing: Text(
        chat['timestamp']!,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              userId: "1",
              partnerId: chat['name']!,
            ),
          ),
        );
      },
    );
  }
}
