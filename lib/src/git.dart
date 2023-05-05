import 'dart:io';

import 'package:git/git.dart';
import 'package:github_pages/src/util.dart';
import 'package:path/path.dart' as p;

/// Represents a local directory
class Git {
  static const _workTreeArg = '--work-tree=';
  static const _gitDirArg = '--git-dir=';

  final String path;

  Git(this.path) : assert(p.isAbsolute(path));

  /// Execute an arbitrary git command.
  Future<ProcessResult> exec(List<String> args) {
    for (final arg in args) {
      requireArgumentNotNullOrEmpty(arg, 'args');
      requireArgument(
        !arg.contains(_workTreeArg),
        'args',
        'Cannot contain $_workTreeArg',
      );
      requireArgument(
        !arg.contains(_gitDirArg),
        'args',
        'Cannot contain $_gitDirArg',
      );
    }

    return runGit(args, processWorkingDir: path);
  }

  /// Initialize repository.
  Future<ProcessResult> init() {
    return exec(['init']);
  }

  /// Clean up unversioned files.
  Future<ProcessResult> clean() {
    return exec(['clean', '-f', '-d']);
  }

  /// Hard reset to remote/branch
  Future<ProcessResult> reset(String remote, String branch) {
    return exec(['reset', '--hard', '$remote/$branch']);
  }

  /// Fetch from a remote.
  Future<ProcessResult> fetch(String remote) {
    return exec(['fetch', remote]);
  }

  /// Checkout a branch (create an orphan if it doesn't exist on the remote).
  Future<ProcessResult> checkout(String remote, String branch) {
    return exec(['ls-remote', '--exit-code', '.', '$remote/$branch']).then(
      (pr) {
        // branch exists on remote, hard reset
        return exec(['checkout', branch])
            .then((pr) => clean())
            .then((pr) => reset(remote, branch));
      },
      onError: (e) {
        if (e is ProcessException && e.errorCode == 2) {
          // branch doesn't exist, create an orphan
          return exec(['checkout', '--orphan', branch]);
        } else {
          // unhandled error
          throw e;
        }
      },
    );
  }

  /// Remove all unversioned files.
  Future<ProcessResult> rm(List<String> files) {
    return exec(['rm', '--ignore-unmatch', '-r', '-f', ...files]);
  }

  /// Add files.
  Future<ProcessResult> add(List<String> files) {
    return exec(['add', ...files]);
  }

  /// Commit (if there are any changes).
  Future<ProcessResult> commit(String message) {
    return exec(['diff-index', '--quiet', 'HEAD'])
        .catchError((e) => exec(['commit', '-m', message]));
  }

  /// Add tag
  Future<ProcessResult> tag(String name) {
    return exec(['tag', name]);
  }

  /// Push a branch.
  Future<ProcessResult> push(String remote, String branch, bool force) {
    final args = ['push', '--tags', '--progress', remote, branch];
    if (force) args.add('--force');
    return exec(args);
  }

  /// Get the URL for a remote.
  Future<String> getRemoteURL(String remote) {
    return exec(['config', '--get', 'remote.$remote.url']).then((pr) {
      final repo = pr.stdout.toString().trim();
      if (repo.isNotEmpty) {
        return repo;
      } else {
        throw GitError(
            'Failed to get repo URL from options or current directory.');
      }
    }).catchError((e) {
      throw GitError('Failed to get remote.$remote.url '
          '(task must either be run in a git repository with a configured $remote remote or must be configured with the "repo" option).');
    });
  }

  /// Delete ref to remove branch history
  Future<ProcessResult> deleteRef(String branch) {
    return exec(['update-ref', '-d', 'refs/heads/$branch']);
  }

  /// Clone a repo into the given dir if it doesn't already exist.
  static Future<Git> clone(
      String repo, String dir, Map<String, dynamic> options) async {
    final git = Git(dir);
    try {
      final args = [
        'clone',
        repo,
        '.',
        '--branch',
        options['branch'].toString(),
        '--single-branch',
        '--origin',
        options['remote'].toString(),
        '--depth',
        options['depth'].toString(),
      ];
      await runGit(args, processWorkingDir: git.path);
    } catch (e) {
      // try again without branch or depth options
      await runGit(
        ['clone', repo, '.', '--origin', options['remote'].toString()],
        processWorkingDir: git.path,
      );
    }
    return git;
  }

  /// Get the path to the .git repository
  static Future<String> getRepo(Map<String, dynamic> options) async {
    if (options['repo'] != null) {
      return options['repo'];
    } else {
      // return Git(p.current).getRemoteURL(options['remote']);
      final pr = await runGit(
        ['rev-parse', '--git-dir'],
        processWorkingDir: p.current,
      );
      if (pr.stdout.toString().trim() == '.git') {
        return p.current;
      }

      throw GitError(
          'The provided value "${p.current}" is not the root of a git directory');
    }
  }
}

Directory createTempDir() => Directory.systemTemp.createTempSync('git.GitDir.');
