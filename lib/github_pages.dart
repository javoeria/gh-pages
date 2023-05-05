import 'dart:io';

import 'package:github_pages/src/git.dart';
import 'package:github_pages/src/util.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as p;

const Map<String, dynamic> defaults = {
  'dest': '.',
  'add': false,
  'git': 'git',
  'depth': 1,
  'dotfiles': false,
  'branch': 'gh-pages',
  'remote': 'origin',
  'src': '**',
  'remove': '.',
  'push': true,
  'history': true,
  'message': 'Updates',
  'silent': false,
};

/// Push a git branch to a remote (pushes gh-pages by default).
Future<void> publish(String dist,
    [Map<String, dynamic> config = const {}]) async {
  final basePath = p.join(p.current, dist);
  final options = Map.of(defaults);
  options.addAll(config);

  if (Directory(basePath).statSync().type != FileSystemEntityType.directory) {
    print('The "dist" option must be an existing directory');
    return;
  }

  final srcFiles = Glob(options['src']).listSync(root: basePath);
  srcFiles
      .retainWhere((file) => file.statSync().type == FileSystemEntityType.file);
  if (!options['dotfiles']) {
    srcFiles.removeWhere((file) => p.basename(file.path).startsWith('.'));
  }
  if (srcFiles.isEmpty) {
    print('The pattern in the "src" option didn\'t match any files.');
    return;
  }

  final temp = createTempDir();
  try {
    final repoUrl = await Git.getRepo(options);
    // print('Cloning $repoUrl into ${temp.path}');
    final git = await Git.clone(repoUrl, temp.path, options);

    final url = await git.getRemoteURL(options['remote']);
    if (url != repoUrl) {
      print('Remote url mismatch. '
          'Got "$url" but expected "$repoUrl" in ${git.path}.');
      return;
    }

    // only required if someone mucks with the checkout between builds
    // print('Cleaning');
    await git.clean();

    // print('Fetching ${options['remote']}');
    await git.fetch(options['remote']);

    // print('Checking out ${options['remote']}/${options['branch']}');
    await git.checkout(options['remote'], options['branch']);

    if (!options['history']) {
      await git.deleteRef(options['branch']);
    }

    if (!options['add']) {
      // print('Removing files');
      if (options['remove'] == defaults['remove']) {
        if (Directory(p.join(git.path, options['dest'])).existsSync()) {
          await git.rm([options['dest']]);
        }
      } else {
        final rmFiles = Glob(options['remove'])
            .listSync(root: p.join(git.path, options['dest']));
        if (rmFiles.isNotEmpty) {
          await git.rm(rmFiles.map((file) => file.path).toList());
        }
      }
    }

    // print('Copying files');
    for (final file in srcFiles) {
      final copyTo = p.join(
          git.path, options['dest'], p.relative(file.path, from: basePath));
      if (p.isWithin(git.path, p.dirname(copyTo))) {
        Directory(p.dirname(copyTo)).createSync(recursive: true);
      }
      File(file.path).copySync(copyTo);
    }

    // print('Adding all');
    await git.add(['.']);

    if (options['user'] != null) {
      final user = parseOneAddress(options['user']);
      await git.exec(['config', 'user.email', user['email']]);
      if (user['name'] != null) {
        await git.exec(['config', 'user.name', user['name']]);
      }
    }

    // print('Committing');
    await git.commit(options['message']);

    if (options['tag'] != null) {
      // print('Tagging');
      try {
        await git.tag(options['tag']);
      } catch (e) {
        // tagging failed probably because this tag alredy exists
        print('Tagging failed, continuing');
      }
    }

    // print('Pushing');
    await git.push(options['remote'], options['branch'], !options['history']);
    if (options['repo'] == null && options['push']) {
      await Git(p.current)
          .push(options['remote'], options['branch'], !options['history']);
    }

    print('Published');
  } catch (e) {
    if (options['silent']) {
      print('Unspecified error (run without silent option for detail)');
    } else {
      print(e);
    }
  } finally {
    temp.deleteSync(recursive: true);
  }
}
