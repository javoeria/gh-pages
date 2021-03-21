import 'dart:io';

import 'package:git/git.dart';
import 'package:path/path.dart' as p;
import 'package:process_run/shell.dart';

/// Push a git branch to a remote (pushes `gh-pages` by default).
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
    if (directory == 'build') {
      directory = p.join(p.current, directory, 'web');
      var exists = await Directory(directory).exists();
      if (!exists) await run('flutter build web');
    } else {
      directory = p.join(p.current, directory);
    }

    await gitDir.updateBranchWithDirectoryContents(branch, directory, message);
    if (push) {
      var args = ['push', remote, branch];
      if (force) args.add('--force');
      await gitDir.runCommand(args);
    }
    print('Published');
  } catch (e) {
    print(e);
  }
}
