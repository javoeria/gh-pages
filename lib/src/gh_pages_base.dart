import 'dart:io';

import 'package:git/git.dart';
import 'package:path/path.dart' as p;

class GitHubPages {
  Future<void> publish() async {
    try {
      final gitDir = await GitDir.fromExisting(p.current);
      await gitDir.updateBranchWithDirectoryContents('gh-pages', p.join(p.current, 'build', 'web'), 'Updates');
      await gitDir.runCommand(['push', 'origin', 'gh-pages']);
      print('Published');
    } on ProcessException catch (e) {
      print(e);
    }
  }
}
