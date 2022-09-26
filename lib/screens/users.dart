import 'package:chirp/api/twitter.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UserDetailsScreen extends StatefulWidget {
  final String id;
  const UserDetailsScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late Future<UserResponse> resp;
  final api = ApiTwitter();
  @override
  void initState() {
    super.initState();
    resp = _fetchData();
  }

  Future<UserResponse> _fetchData() async {
    return await api.lookupUser(widget.id);
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null) {
      return;
    }
    final uri = Uri.parse(url);
    const mode = LaunchMode.externalApplication;
    if (!await launchUrl(uri, mode: mode)) {
      throw 'Could not Launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[300],
      ),
      backgroundColor: Colors.blueGrey[100],
      body: FutureBuilder(
        future: resp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data!.user;
          final a = DateFormat.yMMM().format(user.createdAt);
          return SingleChildScrollView(
            child: GFCard(
              margin: const EdgeInsets.all(8),
              titlePosition: GFPosition.start,
              title: GFListTile(
                avatar: GFAvatar(
                  backgroundImage: NetworkImage(user.profileImageUrl),
                ),
                titleText: user.name,
                subTitleText: '@${user.username}',
              ),
              content: Column(children: [
                Text(user.description ?? ''),
                const SizedBox(height: 16),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    _launchUrl(user.url);
                  },
                  icon: const Icon(Icons.link),
                  label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(user.url ?? ''),
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.today),
                  label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Joined $a'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(0),
                  padding: const EdgeInsets.fromLTRB(4, 2, 0, 0),
                  height: 22,
                  child: Row(children: [
                    Text.rich(TextSpan(
                      children: [
                        TextSpan(
                          text: '${user.publicMetrics.followingCount}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: '  Flowing',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    )),
                    const SizedBox(width: 32),
                    Text.rich(TextSpan(children: [
                      TextSpan(
                        text: '${user.publicMetrics.followersCount}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: '  Flowers',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ])),
                  ]),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}
