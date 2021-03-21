import 'package:args/args.dart';
import 'package:github_pages/github_pages.dart' as ghpages;

void main(List<String> arguments) {
  final parser = ArgParser();
  parser.addOption('dist',
      abbr: 'd',
      help: 'Base directory for all source files',
      defaultsTo: 'build');
  // parser.addOption('src', abbr: 's', help: 'Pattern used to select which files to publish', defaultsTo: '**/*');
  parser.addOption('branch',
      abbr: 'b',
      help: 'Name of the branch you are pushing to',
      defaultsTo: 'gh-pages');
  // parser.addOption('dest', abbr: 'e', help: 'Target directory within the destination branch (relative to the root)', defaultsTo: '.');
  // parser.addFlag('add', abbr: 'a', help: 'Only add, and never remove existing files', negatable: false);
  // parser.addFlag('silent', abbr: 'x', help: 'Do not output the repository url', negatable: false);
  parser.addOption('message',
      abbr: 'm', help: 'Commit message', defaultsTo: 'Updates');
  // parser.addOption('tag', abbr: 'g', help: 'add tag to commit');
  // parser.addOption('git', help: 'Path to git executable', defaultsTo: 'git');
  // parser.addFlag('dotfiles', abbr: 't', help: 'Include dotfiles', negatable: false);
  // parser.addOption('repo', abbr: 'r', help: 'URL of the repository you are pushing to');
  // parser.addOption('depth', abbr: 'p', help: 'depth for clone', defaultsTo: '1');
  parser.addOption('remote',
      abbr: 'o', help: 'The name of the remote', defaultsTo: 'origin');
  // parser.addOption('user', abbr: 'u', help: 'The name and email of the user (defaults to the git config). Format is "Your Name <email@example.com>".');
  // parser.addOption('remove', abbr: 'v', help: 'Remove files that match the given pattern (ignored if used together with --add).', defaultsTo: '.');
  parser.addFlag('no-push',
      abbr: 'n', help: 'Commit only (with no push)', negatable: false);
  parser.addFlag('no-history',
      abbr: 'f',
      help: 'Push force new commit without parent history',
      negatable: false);
  // parser.addOption('before-add', help: 'Execute the function exported by <file> before "git add"');
  parser.addFlag('help', abbr: 'h', help: 'Usage help', negatable: false);

  final results = parser.parse(arguments);
  if (results['help']) {
    print(parser.usage);
  } else {
    ghpages.publish(
      directory: results['dist'],
      branch: results['branch'],
      message: results['message'],
      remote: results['remote'],
      push: !results['no-push'],
      force: results['no-history'],
    );
  }
}
