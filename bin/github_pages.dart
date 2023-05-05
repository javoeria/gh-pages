import 'package:args/args.dart';
import 'package:github_pages/github_pages.dart' as ghpages;

void main(List<String> arguments) {
  final parser = ArgParser();
  parser.addOption('dist',
      abbr: 'd', help: 'Base directory for all source files');
  parser.addOption('src',
      abbr: 's',
      help: 'Pattern used to select which files to publish',
      defaultsTo: ghpages.defaults['src']);
  parser.addOption('branch',
      abbr: 'b',
      help: 'Name of the branch you are pushing to',
      defaultsTo: ghpages.defaults['branch']);
  parser.addOption('dest',
      abbr: 'e',
      help:
          'Target directory within the destination branch (relative to the root)',
      defaultsTo: ghpages.defaults['dest']);
  parser.addFlag('add',
      abbr: 'a',
      help: 'Only add, and never remove existing files',
      negatable: false);
  parser.addFlag('silent',
      abbr: 'x', help: 'Do not output the repository url', negatable: false);
  parser.addOption('message',
      abbr: 'm',
      help: 'Commit message',
      defaultsTo: ghpages.defaults['message']);
  parser.addOption('tag', abbr: 'g', help: 'Add tag to commit');
  // parser.addOption('git', help: 'Path to git executable', defaultsTo: ghpages.defaults['git']);
  parser.addFlag('dotfiles',
      abbr: 't', help: 'Include dotfiles', negatable: false);
  parser.addOption('repo',
      abbr: 'r', help: 'URL of the repository you are pushing to');
  parser.addOption('depth',
      abbr: 'p',
      help: 'Depth for clone',
      defaultsTo: ghpages.defaults['depth'].toString());
  parser.addOption('remote',
      abbr: 'o',
      help: 'The name of the remote',
      defaultsTo: ghpages.defaults['remote']);
  parser.addOption('user',
      abbr: 'u',
      help:
          'The name and email of the user. Format is "Your Name <email@example.com>".\n(defaults to the git config)');
  parser.addOption('remove',
      abbr: 'v',
      help:
          'Remove files that match the given pattern (ignored if used together with --add).',
      defaultsTo: ghpages.defaults['remove']);
  parser.addFlag('no-push',
      abbr: 'n', help: 'Commit only (with no push)', negatable: false);
  parser.addFlag('no-history',
      abbr: 'f',
      help: 'Push force new commit without parent history',
      negatable: false);
  // parser.addOption('before-add', help: 'Execute the function exported by <file> before "git add"');
  parser.addFlag('help',
      abbr: 'h', help: 'Print usage information', negatable: false);

  final results = parser.parse(arguments);
  if (results['help']) {
    print('Usage: github_pages [options]\nOptions:');
    print(parser.usage);
  } else if (results['dist'] == null) {
    print('The "dist" option must be of type String');
  } else {
    ghpages.publish(results['dist'], {
      'repo': results['repo'],
      'silent': results['silent'],
      'branch': results['branch'],
      'src': results['src'],
      'dest': results['dest'],
      'message': results['message'],
      'tag': results['tag'],
      'depth': results['depth'],
      'dotfiles': results['dotfiles'],
      'add': results['add'],
      'remove': results['remove'],
      'remote': results['remote'],
      'push': !results['no-push'],
      'history': !results['no-history'],
      'user': results['user'],
    });
  }
}
