import 'package:flutter/material.dart';
import 'dart:async';
import 'package:project/utils/handleRequest.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class LiveDashboard extends StatefulWidget {
  final dynamic user;
  const LiveDashboard(this.user, {super.key});

  @override
  _LiveDashboardState createState() => _LiveDashboardState();
}

class _LiveDashboardState extends State<LiveDashboard> with AutomaticKeepAliveClientMixin {
  final TextEditingController messageController = TextEditingController();
  // late YoutubePlayerController? _youtubeController;
  // late WebViewController _webViewController;
  Map<String, dynamic>? _livestreamMetadata;

  late ScrollController _scrollController;
  List<Map<String, String>> _messages = [];
  late Timer _timer;

  String html = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchLivestreamMetadata());
    // _startPolling();
  }

  // void _startPolling() {
  //   _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
  //     await _fetchChatMessages();
  //   });
  // }

  Future<void> fetchLivestreamMetadata() async {
    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response =
          await requestHandler.handleRequest(context, 'youtube/get-metadata', type: "get", body: {});
      if (response['success'] == true) {
        if (response['metadata'] != "") {
          // setState(() {
          //   // html = response['url'];
          //   html = '''
          //     <iframe width="100%" height="100%"
          //         src="${response['url']}?autoplay=1&mute=1"
          //         frameborder="0"
          //         allow="autoplay; encrypted-media"
          //         allowfullscreen>
          //     </iframe>
          //   ''';
          // });
          checkAndEmbedVideo(response['url']);
          // checkAndEmbedVideo('https://fb.watch/w5xr3yKRfb/');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void checkAndEmbedVideo(String url) {
    String platform = getPlatformFromUrl(url);

    switch (platform) {
      case 'youtube':
        embedYouTubeVideo(url);
        break;
      case 'facebook':
        embedFacebookVideo(url);
        break;
      case 'instagram':
        embedInstagramVideo(url);
        break;
      case 'twitter':
        embedTwitterVideo(url);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unsupported platform!')),
        );
    }
  }

  String getPlatformFromUrl(String url) {
    String lowerCaseUrl = url.toLowerCase();
    if (lowerCaseUrl.contains('youtube.com') || lowerCaseUrl.contains('youtu.be')) {
      return 'youtube';
    }
    if (lowerCaseUrl.contains('facebook.com') || lowerCaseUrl.contains('fb.')) {
      return 'facebook';
    }
    if (lowerCaseUrl.contains('instagram.com')) {
      return 'instagram';
    }
    if (lowerCaseUrl.contains('twitter.com')) {
      return 'twitter';
    }
    return 'unknown';
  }

  void embedYouTubeVideo(String url) {
    setState(() {
      html = '''
      <iframe width="100%" height="100%" 
          src="$url?autoplay=1&mute=1" 
          frameborder="0" 
          allow="autoplay; encrypted-media" 
          allowfullscreen>
      </iframe>
    ''';
    });
  }

  void embedFacebookVideo(String url) {
    setState(() {
      html = '''
      <iframe src="https://www.facebook.com/plugins/video.php?href=$url" width="100%" height="100%" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
    ''';
    });
  }

  void embedInstagramVideo(String url) {
    setState(() {
      html = '''
      <iframe src="$url" width="100%" height="100%" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
    ''';
    });
  }

  void embedTwitterVideo(String url) {
    setState(() {
      html = '''
      <iframe src="$url" width="100%" height="100%" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
    ''';
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: (html.isNotEmpty)
                ?
                // AbsorbPointer(
                //     absorbing: true,
                //     child: YoutubePlayer(
                //       controller: _youtubeController!,
                //       showVideoProgressIndicator: true,
                //     ),
                //   )
                Container(
                    child: HtmlWidget(
                      html,
                    ),
                  )
                : Container(
                    width: size.width,
                    height: size.height * 0.45,
                    color: Colors.black,
                    child: const Center(
                      child: Text(
                        "Live Stream",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
          ),
          Positioned(
            bottom: size.height * 0.57,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  onPressed: () {
                    _getCurrentProduct();
                  },
                  backgroundColor: Colors.pink,
                  icon: const Icon(Icons.monetization_on, color: Colors.white),
                  label: const Text(
                    'Instamine',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: size.width,
              height: size.height * 0.57,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _buildComment(message);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            sendSpecialMessage(messageController.text);
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Colors.pink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDescriptionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Stream Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _livestreamMetadata!['snippet']['description'] ?? 'No description available.',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    // _youtubeController!.dispose();
    super.dispose();
  }

  Future<void> _fetchChatMessages() async {
    if (html.isEmpty) return;
    RequestHandler requestHandler = RequestHandler();
    try {
      final lastMessageId = _messages.isNotEmpty ? _messages.last['id'] : null;
      Map<String, dynamic> response = await requestHandler.handleRequest(
        context,
        'youtube/fetch-chats',
        willLoadingShow: false,
        body: {
          'lastMessageId': lastMessageId,
        },
      );

      if (response['success'] == true) {
        final List<dynamic> newChats = response['chats'];

        setState(() {
          _messages = [
            ..._messages,
            ...newChats.map((chat) => {
                  'id': chat['id'],
                  'userProfile': chat['userProfile'],
                  'user': chat['user'],
                  'message': chat['message'],
                  'timestamp': chat['timestamp'],
                })
          ];
          if (_messages.length > 30) {
            _messages = _messages.sublist(_messages.length - 30);
          }
        });
        _scrollToBottom();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Error fetching message.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _getCurrentProduct() async {}

  Future<void> sendSpecialMessage(String messageText) async {
    if (html.isEmpty) return;
    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response = await requestHandler.handleRequest(context, 'youtube/send-chat-live', body: {
        'profileSrc': widget.user['profileImage'],
        'user': widget.user['firstName'] + " " + widget.user['lastName'],
        'message': messageText
      });

      if (response['success'] == true) {
        setState(() {
          messageController.text = "";
        });
        setState(() {
          _messages = [
            ..._messages,
            ...[
              {
                'id': "1",
                'userProfile': widget.user['profileImage'],
                'user': widget.user['firstName'] + " " + widget.user['lastName'],
                'message': messageText,
                'timestamp': DateTime.now().toString(),
              }
            ]
          ];
          if (_messages.length > 30) {
            _messages = _messages.sublist(_messages.length - 30);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Error sending message.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      print('An error occurred: $e');
    }
  }

  Widget _buildComment(Map<String, dynamic> message) {
    String messageText = message['message'];
    String userName = message['user'] ?? 'Unknown User';
    String profileImage = message['userProfile'] ?? '';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.pink,
        backgroundImage: profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
        child: profileImage.isEmpty
            ? const Icon(
                Icons.person,
                color: Colors.white,
              )
            : null,
      ),
      title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(messageText),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
