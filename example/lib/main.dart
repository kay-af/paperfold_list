import 'package:flutter/material.dart';
import 'package:paperfold_list/paperfold_list.dart';

void main() {
  runApp(const MainApp());
}

class Post {
  final int id;
  final String userImageUrl;
  final String userName;
  final String content;

  const Post({
    required this.id,
    required this.userImageUrl,
    required this.userName,
    required this.content,
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      home: const SafeArea(
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
  static const List<Post> _posts = [
    Post(
      id: 1,
      userImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
      userName: 'John Miller',
      content: 'Just had a great day at the beach!',
    ),
    Post(
      id: 2,
      userImageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
      userName: 'Jane Smith',
      content: 'Loving the new coffee place downtown.',
    ),
    Post(
      id: 3,
      userImageUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
      userName: 'Michael Johnson',
      content: 'Started a new book today. Excited to dive in!',
    ),
    Post(
      id: 4,
      userImageUrl: 'https://randomuser.me/api/portraits/women/4.jpg',
      userName: 'Emily Davis',
      content: 'Had an amazing dinner with friends.',
    ),
    Post(
      id: 5,
      userImageUrl: 'https://randomuser.me/api/portraits/men/5.jpg',
      userName: 'Chris Brown',
      content: 'Just finished a 5k run. Feeling great!',
    ),
    Post(
      id: 6,
      userImageUrl: 'https://randomuser.me/api/portraits/women/6.jpg',
      userName: 'Sarah Wilson',
      content: 'Baking some cookies today. Can’t wait to taste them!',
    ),
    Post(
      id: 7,
      userImageUrl: 'https://randomuser.me/api/portraits/men/7.jpg',
      userName: 'David Lee',
      content: 'Enjoying a beautiful sunset at the park.',
    ),
    Post(
      id: 8,
      userImageUrl: 'https://randomuser.me/api/portraits/women/8.jpg',
      userName: 'Olivia Martinez',
      content: 'Just finished reading an amazing book!',
    ),
  ];

  final double _itemExtent = 80;

  bool _folded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recent Posts"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPost(_posts.first),
            PaperfoldList.builder(
              targetUnfold: _folded ? 0 : 1,
              itemExtent: _itemExtent,
              itemCount: _posts.length - 2,
              interactionUnfoldThreshold: 1,
              unmountOnFold: true,
              animationCurve: Curves.easeInOut,
              animationDuration: const Duration(milliseconds: 500),
              effect: PaperfoldShadeEffect(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                preBuilder: (context, info, child) => Material(child: child),
              ),
              itemBuilder: (context, index) {
                final post = _posts[index + 1];
                return _buildPost(post);
              },
            ),
            _buildPost(_posts.last),
            const SizedBox(height: 8),
            _buildShowMoreLessButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPost(Post post) {
    return SizedBox(
      height: _itemExtent,
      child: ListTile(
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
      ),
    );
  }

  Widget _buildShowMoreLessButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _folded = !_folded;
        });
      },
      child: Text(_folded ? "Show More" : "Show Less"),
    );
  }
}
