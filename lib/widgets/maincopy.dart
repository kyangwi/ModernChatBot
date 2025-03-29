// import 'package:chatbot/constants/constant.dart';
// import 'package:flutter/material.dart';

// import 'widgets/appbar.dart';
// import './markdown/genearal.dart';
// import 'package:langchain_google/langchain_google.dart';
// import 'package:langchain/langchain.dart';
// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'AWC Assistant',
//       // theme: ThemeData(primarySwatch: Colors.blue),
//       home: ChatBotScreen(),
//     );
//   }
// }

// class ChatBotScreen extends StatefulWidget {
//   const ChatBotScreen({super.key});

//   @override
//   _ChatBotScreenState createState() => _ChatBotScreenState();
// }

// class _ChatBotScreenState extends State<ChatBotScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final List<Map<String, String>> _messages = [];
//   bool _isLoading = false;

//   final generativeModel = ChatGoogleGenerativeAI(apiKey: Constants.apiKey);
//   final memory = ConversationBufferMemory(returnMessages: false);

//   // / Scrolls the ListView to the bottom.
//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }
  


//   Future<void> _sendMessage(String prompt) async {
//     if (prompt.trim().isEmpty) return;

//     // Immediately clear the text field upon sending.
//     _controller.clear();

//     // Add a placeholder for the user's message.
//     setState(() {
//       _messages.add({'user': ''});
//     });
//     _scrollToBottom();

//     // Get the index of the newly added user message.
//     int userMessageIndex = _messages.length - 1;
//     final words = prompt.split(' ');

//     // Reveal the user's prompt word-by-word.
//     for (var word in words) {
//       await Future.delayed(Duration(milliseconds: 100));
//       setState(() {
//         _messages[userMessageIndex]['user'] = '${_messages[userMessageIndex]['user'] ?? ''}$word ';
//       });
//       _scrollToBottom();
//     }

//     // Set _isLoading to true to disable the send button.
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final conversation = ConversationChain(
//         llm: generativeModel,
//         memory: memory,
//       );

//       final response = await conversation.run(prompt);

//       int start = response.indexOf("content:") + "content:".length;
//       int end = response.indexOf(",\n", start);
//       String fullResponse = response.substring(start, end).trim();

//       // Add a bot message placeholder.
//       setState(() {
//         _messages.add({'bot': ''});
//       });
//       _scrollToBottom();

//       // Get the index of the newly added bot message.
//       int botMessageIndex = _messages.length - 1;
//       final botWords = fullResponse.split(' ');

//       // Reveal the bot's response word-by-word.
//       for (var word in botWords) {
//         await Future.delayed(Duration(milliseconds: 50));
//         setState(() {
//           _messages[botMessageIndex]['bot'] =
//               '${_messages[botMessageIndex]['bot'] ?? ''}$word ';
//         });
//         _scrollToBottom();
//       }
//     } catch (error) {
//       setState(() {
//         _messages.add({'bot': 'error: ${error.toString()}'});
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: Bar(),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               padding: EdgeInsets.all(8.0),
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final message = _messages[index];
//                 final isUser = message.containsKey('user');
//                 return Align(
//                   alignment:
//                       isUser ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     padding: EdgeInsets.all(12.0),
//                     margin: EdgeInsets.symmetric(vertical: 4.0),
//                     decoration: BoxDecoration(
//                       color: isUser ? Colors.blue[50] : Colors.grey[45],
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(16.0),
//                         topRight: Radius.circular(16.0),
//                         bottomLeft:
//                             isUser ? Radius.circular(16.0) : Radius.zero,
//                         bottomRight:
//                             isUser ? Radius.zero : Radius.circular(16.0),
//                       ),
//                     ),
//                     child: isUser
//                         ? Text(
//                             message['user']!,
//                             style: TextStyle(
//                               fontSize: 16.0,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           )
//                         : MarkdownFormattedText(text: message['bot']!),
//                   ),
//                 );
//               },
//             ),
//           ),
//           // Input field with integrated send icon.
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _controller,
//               onSubmitted: _isLoading ? null : (value) => _sendMessage(value),
//               decoration: InputDecoration(
//                 hintText: 'Type your prompt...',
//                 // Customize the border of the TextField
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(25.0),
//                   borderSide: BorderSide(
//                     color: Colors.blueGrey,
//                     width: 2,
//                   ),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(25.0),
//                   borderSide: BorderSide(
//                     color: Colors.blueGrey,
//                     width: 2,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(25.0),
//                   borderSide: BorderSide(
//                     color: Colors.blueGrey,
//                     width: 2,
//                   ),
//                 ),
//                 filled: true,
//                 fillColor: Colors.white30,
//                 suffixIcon: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: _isLoading
//                       ? SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               Colors.blueGrey,
//                             ),
//                           ),
//                         )
//                       : GestureDetector(
//                           onTap: () => _sendMessage(_controller.text),
//                           child: Container(
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.blueGrey,
//                             ),
//                             padding: EdgeInsets.all(8.0),
//                             child: Icon(
//                               Icons.arrow_upward,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                           ),
//                         ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
