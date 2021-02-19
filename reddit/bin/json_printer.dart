import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:path/path.dart' as path;
import 'package:reddit/reddit.dart' hide RedditEndpoints;
// We hid the [RedditEndpoints] extension above in order to import the [RawRedditEndpoints]
// extension below.
import 'package:reddit/src/endpoints/raw_endpoints.dart';

import 'reddit_credentials.dart';

void main() async {
  final io = Client();

  final anon = createScriptClient(
      clientId: Credentials.scriptId,
      clientSecret: Credentials.scriptSecret,
      ioClient: io);

  final outputDir = path.join(path.dirname(Platform.script.toFilePath()), 'json');

  print('json_printer turned on');

  const decoder = JsonDecoder();
  const encoder = JsonEncoder.withIndent('  ');
  Future<void> _printJson(String outFile, Future<String> request) async {
    print('printing json/${outFile}...');
    final result = await request;
    final out = File(path.join(outputDir, outFile));
    await out.create(recursive: true);
    await out.writeAsString(encoder.convert(decoder.convert(result)));
  }

  await _printJson(
      'anon_subreddit.json',
      anon.getSubreddit('pics'));

  await _printJson(
      'anon_subreddit_posts.json',
      anon.getSubredditPosts('pics', Page(), SubredditSort.top, TimeSort.all));

  await _printJson(
      'anon_post_comments.json',
      anon.getPostComments(
          '/r/pics/comments/haucpf/ive_found_a_few_funny_memories_during_lockdown/',
          CommentsSort.best));

  final user = createScriptClient(
      clientId: Credentials.scriptId,
      clientSecret: Credentials.scriptSecret,
      username: Credentials.scriptUsername,
      password: Credentials.scriptPassword,
      ioClient: io);

  await _printJson(
      'user_subreddit.json',
      user.getSubreddit('pics'));

  await _printJson(
      'user_subreddit_posts.json',
      anon.getSubredditPosts('pics', Page(), SubredditSort.top, TimeSort.all));

  await _printJson(
      'anon_post_comments.json',
      anon.getPostComments(
          '/r/pics/comments/haucpf/ive_found_a_few_funny_memories_during_lockdown/',
          CommentsSort.best));

  print('json_printer turning off...');
}
