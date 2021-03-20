import 'dart:io';

import 'package:git/git.dart';
import 'package:path/path.dart' as p;

class GitHubPages {
  Future<void> publish({
    String directory = 'build',
    String branch = 'gh-pages',
    String message = 'Updates',
    String remote = 'origin',
    bool push = true,
    bool force = false,
  }) async {
    try {
      final gitDir = await GitDir.fromExisting(p.current);
      await gitDir.updateBranchWithDirectoryContents(branch, p.join(p.current, directory, 'web'), message);
      if (push) {
        var args = ['push', remote, branch];
        if (force) args.add('--force');
        await gitDir.runCommand(args);
      }
      print('Published');
    } on ProcessException catch (e) {
      print(e);
    }
  }
}
