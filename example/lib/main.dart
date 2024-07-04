import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paperfold_list/paperfold_list.dart';

void main() {
  runApp(const MainApp());
}

class Post {
  final int id;
  final String userImageUrl;
  final String userName;
  final String content;
  final DateTime timestamp;

  const Post({
    required this.id,
    required this.userImageUrl,
    required this.userName,
    required this.content,
    required this.timestamp,
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: ExamplePage(),
      ),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final List<Post> _posts = [
    Post(
      id: 1,
      userImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
      userName: 'John Doe',
      content: 'Just had a great day at the beach!',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
    Post(
      id: 2,
      userImageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
      userName: 'Jane Smith',
      content: 'Loving the new coffee place downtown.',
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
    ),
    Post(
      id: 3,
      userImageUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
      userName: 'Michael Johnson',
      content: 'Started a new book today. Excited to dive in!',
      timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
    ),
    Post(
      id: 4,
      userImageUrl: 'https://randomuser.me/api/portraits/women/4.jpg',
      userName: 'Emily Davis',
      content: 'Had an amazing dinner with friends.',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    Post(
      id: 5,
      userImageUrl: 'https://randomuser.me/api/portraits/men/5.jpg',
      userName: 'Chris Brown',
      content: 'Just finished a 5k run. Feeling great!',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    ),
    Post(
      id: 6,
      userImageUrl: 'https://randomuser.me/api/portraits/women/6.jpg',
      userName: 'Sarah Wilson',
      content: 'Baking some cookies today. Can’t wait to taste them!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    Post(
      id: 7,
      userImageUrl: 'https://randomuser.me/api/portraits/men/7.jpg',
      userName: 'David Lee',
      content: 'Enjoying a beautiful sunset at the park.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
    ),
    Post(
      id: 8,
      userImageUrl: 'https://randomuser.me/api/portraits/women/8.jpg',
      userName: 'Olivia Martinez',
      content: 'Just finished reading an amazing book!',
      timestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 50)),
    ),
  ];

  bool _folded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text("Posts"),
        actions: [
          IconButton(
            onPressed: () => setState(() => _folded = !_folded),
            icon: Icon(_folded ? Icons.expand_more : Icons.expand_less),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPost(_posts.first),
            PaperfoldList.builder(
              targetUnfold: _folded ? 0 : 1,
              itemExtent: 80,
              itemCount: _posts.length - 2,
              interactionUnfoldThreshold: 1,
              animationDuration: const Duration(milliseconds: 350),
              animationCurve: _folded ? Curves.easeInSine : Curves.easeOutSine,
              unmountOnFold: true,
              effect: PaperfoldShadeEffect(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                preBuilder: (context, info, child) => Material(child: child),
                outwardCrease: Colors.white,
              ),
              itemBuilder: (context, index) {
                final post = _posts[index + 1];
                return _buildPost(post);
              },
            ),
            _buildPost(_posts.last),
          ],
        ),
      ),
    );
  }

  Widget _buildPost(Post post) {
    final df = DateFormat.yMd();
    return ListTile(
      onTap: () {},
      leading: CircleAvatar(
        foregroundImage: NetworkImage(post.userImageUrl),
      ),
      title: Text(post.userName),
      subtitle: Text(
        post.content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        df.format(post.timestamp),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
